#pragma once

#include <QList>
#include <QString>
#include <QUndoCommand>

class BudgetData;
class Account;
class AccountListModel;
class Operation;
class OperationListModel;

// Command for renaming an account
class RenameAccountCommand : public QUndoCommand {
public:
  RenameAccountCommand(Account *account, AccountListModel *accountModel,
                       const QString &oldName, const QString &newName,
                       QUndoCommand *parent = nullptr);

  void undo() override;
  void redo() override;

private:
  Account *_account;
  AccountListModel *_accountModel;
  QString _oldName;
  QString _newName;
};

// Command for importing operations from CSV
class ImportOperationsCommand : public QUndoCommand {
public:
  ImportOperationsCommand(Account *account, OperationListModel *operationModel,
                          const QList<Operation *> &operations,
                          QUndoCommand *parent = nullptr);
  ~ImportOperationsCommand();

  void undo() override;
  void redo() override;

private:
  Account *_account;
  OperationListModel *_operationModel;
  QList<Operation *> _operations;
  bool _ownsOperations;  // True when operations are not in the account (after undo)
};
