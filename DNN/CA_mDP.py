import math
import numpy as np
import pandas as pd
import os
import csv
from tqdm import tqdm
import torch 
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader, random_split
from torchviz import make_dot
from torch.utils.tensorboard import SummaryWriter

'''
This is how we use Deep Neural Network to train a model to predict the conditional independence status given specific features of mobile vehicles
'''

def same_seed(seed): 
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)
    print(f'Set Seed = {seed}')

def train_valid_split(data_set, valid_ratio, seed):
    valid_set_size = int(valid_ratio * len(data_set)) 
    train_set_size = len(data_set) - valid_set_size
    train_set, valid_set = random_split(data_set, [train_set_size, valid_set_size], generator=torch.Generator().manual_seed(seed))
    return np.array(train_set), np.array(valid_set)

def predict(test_loader, model, device):
    model.eval()
    preds = []
    for x in tqdm(test_loader):
        x = x.to(device)                        
        with torch.no_grad():
            pred = model(x)         
            preds.append(pred.detach().cpu())   
    preds = torch.cat(preds, dim=0).numpy()  
    return preds

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

def select_feat(train_data, valid_data, test_data, select_all=True):
    y_train, y_valid = train_data[:,-1], valid_data[:,-1]
    raw_x_train, raw_x_valid, raw_x_test = train_data[:,:-1], valid_data[:,:-1], test_data

    if select_all:
        feat_idx = list(range(raw_x_train.shape[1]))
    else:
        feat_idx = [0,1,2,3,4]

    return raw_x_train[:,feat_idx], raw_x_valid[:,feat_idx], raw_x_test[:,feat_idx], y_train, y_valid

def trainer(train_loader, valid_loader, model, config, device):
    criterion = nn.BCELoss(reduction='mean')

    # optimizer = torch.optim.SGD(model.parameters(), lr=config['learning_rate'], momentum=0.9)
    optimizer = torch.optim.Adam(model.parameters(), lr=config['learning_rate'])
    writer = SummaryWriter()

    if not os.path.isdir('./models'):
        os.mkdir('./models')

    n_epochs, best_loss, step, early_stop_count = config['n_epochs'], math.inf, 0, 0

    for epoch in range(n_epochs):
        model.train()
        loss_record = []

        train_pbar = tqdm(train_loader, position=0, leave=True)
        
        train_pbar.set_description(f'Epoch [{epoch+1}/{n_epochs}]')
        for x, y in train_pbar:
            optimizer.zero_grad()              
            x, y = x.to(device), y.to(device)  
            pred = model(x)             
            loss = criterion(pred, y)
            loss.backward()                
            optimizer.step()           
            step += 1
            loss_record.append(loss.detach().item())
            
            train_pbar.set_postfix({'loss': loss.detach().item()})

        mean_train_loss = sum(loss_record)/len(loss_record)
        writer.add_scalar('Loss/train', mean_train_loss, step)

        model.eval()
        loss_record = []
        for x, y in valid_loader:
            x, y = x.to(device), y.to(device)
            with torch.no_grad():
                pred = model(x)
                loss = criterion(pred, y)

            loss_record.append(loss.item())
            
        mean_valid_loss = sum(loss_record)/len(loss_record)
        print(f'Epoch [{epoch+1}/{n_epochs}]: Train loss: {mean_train_loss:.4f}, Valid loss: {mean_valid_loss:.4f}')
        writer.add_scalar('Loss/valid', mean_valid_loss, step)

        if mean_valid_loss < best_loss:
            best_loss = mean_valid_loss
            torch.save(model.state_dict(), config['save_path'])
            print('Saving model with loss {:.3f}...'.format(best_loss))
            early_stop_count = 0
        else: 
            early_stop_count += 1

        if early_stop_count >= config['early_stop']:
            print('\nModel is not improving, so we halt the training session.')
            return

def save_pred(preds, file):
    with open(file, 'w') as fp:
        writer = csv.writer(fp)
        writer.writerow(['id', 'pvalue'])
        for i, p in enumerate(preds):
            writer.writerow([i, p])

device = 'cuda' if torch.cuda.is_available() else 'cpu'

config = {
    'seed': 666,
    'select_all': False,
    'valid_ratio': 0.25,
    'n_epochs': 10000,
    'batch_size': 128, 
    'learning_rate': 1e-5,              
    'early_stop': 400,  
    'save_path': './models/model.ckpt'
}

same_seed(config['seed'])

pd.set_option('display.max_column', 200)
train_df, test_df = pd.read_csv('train_data.csv'), pd.read_csv('sample size/1000_test.csv')
print(train_df.head(3))
train_data, test_data = train_df.values, test_df.values
del train_df, test_df
train_data, valid_data = train_valid_split(train_data, config['valid_ratio'], config['seed'])

print(f"""train_data size: {train_data.shape} 
valid_data size: {valid_data.shape} 
test_data size: {test_data.shape}""")

x_train, x_valid, x_test, y_train, y_valid = select_feat(train_data, valid_data, test_data, config['select_all'])

print(f'number of features: {x_train.shape[1]}')

print(device)

train_dataset, valid_dataset, test_dataset = locationDataset(x_train, y_train), \
                                            locationDataset(x_valid, y_valid), \
                                            locationDataset(x_test)
train_loader = DataLoader(train_dataset, batch_size=config['batch_size'], shuffle=True, pin_memory=True)
valid_loader = DataLoader(valid_dataset, batch_size=config['batch_size'], shuffle=True, pin_memory=True)
test_loader = DataLoader(test_dataset, batch_size=config['batch_size'], shuffle=False, pin_memory=True)

# start training
model = My_Model(input_dim=x_train.shape[1]).to(device)
trainer(train_loader, valid_loader, model, config, device)

# test part
model = My_Model(input_dim=x_train.shape[1]).to(device)
model.load_state_dict(torch.load(config['save_path']))
preds = predict(test_loader, model, device) 
save_pred(preds, 'pred.csv')