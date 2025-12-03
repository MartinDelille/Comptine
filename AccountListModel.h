#pragma once

#include "Account.h"
#include <QAbstractListModel>

class AccountListModel : public QAbstractListModel {
  Q_OBJECT

  Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
  Q_PROPERTY(bool includeNewAccountOption READ includeNewAccountOption 
             WRITE setIncludeNewAccountOption NOTIFY includeNewAccountOptionChanged)

public:
  enum Roles {
    NameRole = Qt::UserRole + 1,
    OperationCountRole,
    AccountRole
  };
  Q_ENUM(Roles)

  explicit AccountListModel(QObject *parent = nullptr);

  // QAbstractListModel interface
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  QVariant data(const QModelIndex &index, int role) const override;
  QHash<int, QByteArray> roleNames() const override;

  // Account list management
  void setAccounts(QList<Account *> *accounts);
  void refresh();

  // For import dialog "New account" option
  bool includeNewAccountOption() const { return _includeNewAccountOption; }
  void setIncludeNewAccountOption(bool include);

  // Check if index is the "New account" option
  Q_INVOKABLE bool isNewAccountOption(int index) const;

signals:
  void countChanged();
  void includeNewAccountOptionChanged();

private:
  QList<Account *> *_accounts = nullptr;
  bool _includeNewAccountOption = false;
};
