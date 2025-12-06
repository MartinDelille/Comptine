#include "UndoCommands.h"
#include "Account.h"
#include "AccountListModel.h"
#include "OperationListModel.h"

RenameAccountCommand::RenameAccountCommand(Account *account,
                                           AccountListModel *accountModel,
                                           const QString &oldName,
                                           const QString &newName,
                                           QUndoCommand *parent) :
    QUndoCommand(parent), _account(account), _accountModel(accountModel), _oldName(oldName), _newName(newName) {
  setText(QObject::tr("Rename account to \"%1\"").arg(newName));
}

void RenameAccountCommand::undo() {
  if (_account) {
    _account->set_name(_oldName);
    if (_accountModel) {
      _accountModel->refresh();
    }
  }
}

void RenameAccountCommand::redo() {
  if (_account) {
    _account->set_name(_newName);
    if (_accountModel) {
      _accountModel->refresh();
    }
  }
}

ImportOperationsCommand::ImportOperationsCommand(Account *account,
                                                 OperationListModel *operationModel,
                                                 const QList<Operation *> &operations,
                                                 QUndoCommand *parent) :
    QUndoCommand(parent), _account(account), _operationModel(operationModel), _operations(operations), _ownsOperations(false) {
  setText(QObject::tr("Import %n operation(s)", "", operations.size()));
}

ImportOperationsCommand::~ImportOperationsCommand() {
  // If we own the operations (they were undone), delete them
  if (_ownsOperations) {
    qDeleteAll(_operations);
  }
}

void ImportOperationsCommand::undo() {
  if (!_account) return;

  // Remove operations from account (don't delete them, we keep ownership)
  for (Operation *op : _operations) {
    _account->removeOperation(op);
  }
  _ownsOperations = true;

  // Refresh the model if it's showing this account
  if (_operationModel) {
    _operationModel->refresh();
  }
}

void ImportOperationsCommand::redo() {
  if (!_account) return;

  // Re-add operations to account
  for (Operation *op : _operations) {
    _account->addOperation(op);
  }
  _ownsOperations = false;

  // Refresh the model if it's showing this account
  if (_operationModel) {
    _operationModel->refresh();
  }
}
