"""Camada de fornecimento de dados do veículo."""

from app.data.data_provider import DataProvider, DataProviderCallback, ProviderState
from app.data.demo_provider import DemoDataProvider

__all__ = ["DataProvider", "DataProviderCallback", "DemoDataProvider", "ProviderState"]
