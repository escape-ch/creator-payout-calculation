from sklearn.base import BaseEstimator, TransformerMixin
import numpy as np

# Custom Winsorization Transformer
class Winsorizer(BaseEstimator, TransformerMixin):
    def __init__(self, lower_quantile=0.1, upper_quantile=0.9):
        self.lower_quantile = lower_quantile
        self.upper_quantile = upper_quantile

    def fit(self, X, y=None):
        # Compute quantile thresholds
        self.lower_ = np.quantile(X, self.lower_quantile, axis=0)
        self.upper_ = np.quantile(X, self.upper_quantile, axis=0)
        return self

    def transform(self, X):
        # Clip values to [lower_, upper_]
        X_clipped = np.clip(X, self.lower_, self.upper_)
        return X_clipped


class FeatureMultiplier(BaseEstimator, TransformerMixin):
    def __init__(self, weights):
        self.weights = np.array(weights)

    def fit(self, X, y=None):
        if self.weights.shape[0] != X.shape[1]:
            raise ValueError("Length of weights must match number of features")
        return self

    def transform(self, X):
        return X * self.weights  # element-wise multiplication


class Average(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        # Take the mean across features (axis=1) after weighting
        return X.mean(axis=1).reshape(-1, 1)