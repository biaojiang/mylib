# setup_tf_env.sh

Sets up a Python 3.12 virtual environment (`~/envs/tf`) for TensorFlow development with support for VS Code and Jupyter.

## Features

- Creates venv with Homebrew Python 3.12
- Installs:
  - `tensorflow`
  - `ipykernel`, `ipython`, `ipywidgets`
  - `matplotlib`, `pandas`, `seaborn`
  - `scikit-learn`, `scipy`, `numpy`
- Registers Jupyter kernel: **"Python 3.12 (tf)"**

## Usage

```bash
chmod +x zsh/setup_tf_env.sh
./zsh/setup_tf_env.sh
```

## Notes

- Works seamlessly in **VS Code** (`Python 3.12.10 ('tf')`)
- Kernel registration is optional in VS Code but included for compatibility

To remove the kernel later:

```bash
jupyter kernelspec uninstall tf
```
