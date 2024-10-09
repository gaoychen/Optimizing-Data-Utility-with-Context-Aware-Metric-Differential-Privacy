import pandas as pd
import torch 
import csv
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader

class My_Model(nn.Module):
    def __init__(self, input_dim):
        super(My_Model, self).__init__()
        self.layers = nn.Sequential(
            nn.Linear(input_dim, 16),
            nn.ReLU(),
            nn.Linear(16, 8),
            nn.ReLU(),
            nn.Linear(8, 1),
            nn.Sigmoid()
        )
    def forward(self, x):
        x = self.layers(x)
        x = x.squeeze(1) # (B, 1) -> (B)
        return x

class locationDataset(Dataset):
    def __init__(self, x, y=None):
        if y is None:
            self.y = y
        else:
            self.y = torch.FloatTensor(y)
        self.x = torch.FloatTensor(x)

    def __getitem__(self, idx):
        if self.y is None:
            return self.x[idx]
        return self.x[idx], self.y[idx]

    def __len__(self):
        return len(self.x)

def predict(test_loader, model, device):
    model.eval()
    preds = []
    for x in test_loader:
        x = x.to(device)                        
        with torch.no_grad():
            pred = model(x)         
            preds.append(pred.detach().cpu())   
    preds = torch.cat(preds, dim=0).numpy()  
    return preds

def save_pred(preds, file):
    with open(file, 'w') as fp:
        writer = csv.writer(fp)
        writer.writerow(['id', 'pvalue'])
        for i, p in enumerate(preds):
            writer.writerow([i, p])

def DNN_test():
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    test_data = pd.read_csv('DNN/test_data.csv').values
    test_dataset = locationDataset(test_data)
    test_loader = DataLoader(test_dataset, batch_size=128, shuffle=False, pin_memory=True)
    model = My_Model(input_dim=5).to(device)
    model.load_state_dict(torch.load('DNN/models/model.ckpt'))
    preds = predict(test_loader, model, device) 
    save_pred(preds, 'pred.csv')
    df = pd.read_csv('pred.csv')
    df['CI'] = (df.iloc[:, 1] >= 0.4).astype(int)
    df.to_csv('pred.csv', index=False)