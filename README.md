
# RTGD-MVC: Robust Tensor Learning with Graph Diffusion for Scalable Multi-view Graph Clustering
![Project Structure](https://img.shields.io/badge/Structure-MATLAB-blue)
![License](https://img.shields.io/badge/License-MIT-green)

This repository provides the official MATLAB implementation for the paper *"RTGD-MVC: Robust Tensor Learning with Graph Diffusion for Scalable Multi-view Graph Clustering"*.  

**Key Features**:  
🔹 Robust Tensor Learning with Graph Diffusion for Scalable Multi-view Graph Clustering.    
🔹 One-click reproducible experiments with hyperparameter optimization  
🔹 Comprehensive baseline comparisons (see `baseline/` directory)  
🔹 Supports common datasets (BBC, BDGP, CCV, etc.).  

---

## 📋 Table of Contents
1. [Requirements](#-requirements)  
2. [Project Structure](#-project-structure)
3. [Quick Start](#-quick-start)  
4. [Dataset Preparation](#-dataset-preparation)  
5. [Output Results](#-output-results)  
6. [Parameters](#-parameters)  
7. [License](#-license)  

---

## 🛠 Requirements
- **MATLAB ≥ R2019b**  
- **MATLAB Toolboxes**:  
  - Statistics and Machine Learning Toolbox  
  - (Optional) Parallel Computing Toolbox (for large datasets)  

---

## 📂 Project Structure
```bash
RTGD-MVC/
├── data/                   # Dataset storage
│   └── BBC.mat             # Sample dataset file
├── exp/                    # Experiment scripts
│   ├── run_demo.m          # Main experiment script
│   └── result_RTGD-MVC/    # Results storage (auto-generated)
├── lib/                    # Utility functions
│   └── NormalizeFea.m      # Data normalization
├── utils/                  # Core algorithm implementation
│   ├── Construct_FB.m      # Anchor graph construction
│   └──RTGD.m              # Main algorithm function
├── baseline/               # Baseline implementations
│   ├── AWMVC/              # Adaptive Weighted MVC
│   ├── FPMVS-CAG/          # Fast Probabilistic MVC
│   └── ...                 # Other baselines
└── docs/                   # Supplementary materials
```
---

## 🚀 Quick Start
### Step 1: Clone the Repository
The code is publicly available at 'https://anonymous.4open.science/r/RTGD-MVC-6646/'

### Step 2: Run the Demo
1. **Launch MATLAB** and navigate to the `exp` folder:  
   ```matlab
   cd /path/to/RTGD-MVC/exp
   ```
2. **Execute the demo script**:  
   ```matlab
   run run_demo.m
   ```
3. **Results** will be saved in `exp/result_RTGD-MVC/`.

---

## 📁 Dataset Preparation
1. **Place Your Dataset**  
   - Save your dataset as a `.mat` file in the `data/` folder.  
   - Example: For dataset `mydata`, save it as `data/mydata.mat`.  

2. **Dataset Format Requirements**  
   Ensure your `.mat` file contains:  
   ```matlab
   % Variables:
   % - X: Cell array of multi-view data {nView × 1}, each view is [nSmp × nFeature]
   % - Y: Ground truth labels [nSmp × 1]
   load('mydata.mat'); 
   ```

**🔄 Example Workflow**
1. Add `mydata.mat` to `data/`:  
   ```
   RTGD-MVC/
   └── data/
       └── mydata.mat
   ```
2. Set `dataset = 'mydata';` in `run_demo.m`  
3. Run the code. Results will use your custom dataset.

---





## 📊 Output Results
### 📂 Results Storage Structure
#### Output Path Format
The experimental results will be saved in the following directory structure:  
```
exp/result_RTGD-MVC/
└── {dataset_name}/               # e.g., BBC/
    ├── {dataset_name}_RTGD.mat   # Aggregated results (best parameters)
    └── {dataset_name}_RTGD_param{1-N}.mat   # Per-parameter results
```

#### Example for BBC Dataset
```
D:\Sean\MVC\RTGD-MVC\exp\result_RTGD-MVC\BBC\
├── BBC_RTGD.mat                 # Best results across all parameters
├── BBC_RTGD_param1.mat          # Results for parameter set 1
├── BBC_RTGD_param2.mat          # Results for parameter set 2
└── ...                          # Additional parameter results
```

### 🗂️ File Contents
#### 1. Aggregated Results File (`BBC_RTGD.mat`)
| Variable                  | Description                          | MATLAB Access Command        |
|---------------------------|--------------------------------------|------------------------------|
| `RTGD_global_result`      | Metrics for all parameter sets       | `load('BBC_RTGD.mat')`       |
| `RTGD_global_time`        | Average runtime per parameter set    | `disp(RTGD_global_time)`     |
| `RTGD_global_result_summary` | Best metrics (ACC/NMI/PUR + time)  | `disp(RTGD_global_result_summary)` |
| `iParam_max`              | Index of best-performing parameters  | `disp(iParam_max)`           |

#### 2. Per-Parameter Results (`BBC_RTGD_param1.mat`)
| Variable          | Description                          |
|-------------------|--------------------------------------|
| `temp_grid_ans`   | Metrics for a specific parameter set |
| Example Metrics:  | `[ACC, NMI, PUR, Time]`              |

---

### ⚙ Parameters
Key parameters in `run_demo.m`:
```matlab
% Hyperparameter grid search ranges:
lambda_s = 10.^(-6:1:0);  % Sparse error weight (1e-6 to 1)
delta_s = 10.^(-6:1:0);   % Convergence threshold (1e-6 to 1)
nAnch_s = nClus.*(2:1:8); % Anchors: 2×nClus to 8×nClus
ks_s = [10];               % k-Nearest Neighbors
eta_s = [1];               % Graph regularization
```

| Parameter  | Description                              | Search Range / Values          |
|------------|------------------------------------------|---------------------------------|
| `nClus`    | Number of clusters                      | Dataset-specific (e.g., 4)      |
| `nAnch`    | Number of anchors                       | `2×nClus` to `8×nClus`          |
| `ks`       | k-Nearest Neighbors for graph building   | `10`                            |
| `eta`      | Graph regularization coefficient        | `1`                             |
| `lambda`   | Sparse error weight                     | `10⁻⁶` (1e-6) to `1` (log scale)|
| `delta`    | Convergence threshold                    | `10⁻⁶` (1e-6) to `1` (log scale)|

---


## 📜 License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.


