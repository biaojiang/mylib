#!/bin/zsh

# Define env path
ENV_PATH=~/envs/tf
PYTHON312=python3.12

echo "🔧 Creating virtual environment at $ENV_PATH using Python 3.12..."
$PYTHON312 -m venv $ENV_PATH

echo "✅ Activating environment..."
source $ENV_PATH/bin/activate

echo "⬆️ Upgrading pip..."
pip install --upgrade pip

echo "📦 Installing TensorFlow, Jupyter kernel, widgets, and data tools..."
pip install tensorflow ipykernel ipython ipywidgets numpy scipy matplotlib pandas seaborn scikit-learn

# The following is not necessary for VS Code
# echo "🧠 Registering kernel with Jupyter as 'Python (tf)'..."
# python -m ipykernel install --user --name=tf --display-name "Python 3.12 (tf)"

# echo "🎉 Done! Virtual environment 'tf' is ready for VS Code."
# echo "🧪 You can now select 'Python 3.12 (tf)' as the kernel in VS Code notebooks."

