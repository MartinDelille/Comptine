#include "AccountListModel.h"
#include <QCoreApplication>

AccountListModel::AccountListModel(QObject *parent)
    : QAbstractListModel(parent) {}

int AccountListModel::rowCount(const QModelIndex &parent) const {
  if (parent.isValid() || !_accounts)
    return 0;

  int count = _accounts->size();
  if (_includeNewAccountOption) {
    count += 1;  // Extra row for "New account"
  }
  return count;
}

QVariant AccountListModel::data(const QModelIndex &index, int role) const {
  if (!index.isValid() || !_accounts)
    return QVariant();

  const int row = index.row();
  const int accountCount = _accounts->size();

  // Check if this is the "New account" option
  if (_includeNewAccountOption && row == accountCount) {
    switch (role) {
    case NameRole:
      return QCoreApplication::translate("AccountListModel", "New account");
    case OperationCountRole:
      return 0;
    case AccountRole:
      return QVariant();  // No account object for "New account"
    default:
      return QVariant();
    }
  }

  if (row < 0 || row >= accountCount)
    return QVariant();

  Account *account = _accounts->at(row);
  if (!account)
    return QVariant();

  switch (role) {
  case NameRole:
    return account->name();
  case OperationCountRole:
    return account->operationCount();
  case AccountRole:
    return QVariant::fromValue(account);
  default:
    return QVariant();
  }
}

QHash<int, QByteArray> AccountListModel::roleNames() const {
  return {
      {NameRole, "name"},
      {OperationCountRole, "operationCount"},
      {AccountRole, "account"}
  };
}

void AccountListModel::setAccounts(QList<Account *> *accounts) {
  if (_accounts == accounts)
    return;

  beginResetModel();
  _accounts = accounts;
  endResetModel();

  emit countChanged();
}

void AccountListModel::refresh() {
  beginResetModel();
  endResetModel();
  emit countChanged();
}

void AccountListModel::setIncludeNewAccountOption(bool include) {
  if (_includeNewAccountOption == include)
    return;

  if (include) {
    // Adding a row at the end
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    _includeNewAccountOption = true;
    endInsertRows();
  } else {
    // Removing the last row
    beginRemoveRows(QModelIndex(), rowCount() - 1, rowCount() - 1);
    _includeNewAccountOption = false;
    endRemoveRows();
  }

  emit includeNewAccountOptionChanged();
  emit countChanged();
}

bool AccountListModel::isNewAccountOption(int index) const {
  if (!_includeNewAccountOption || !_accounts)
    return false;
  return index == _accounts->size();
}
