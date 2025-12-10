#pragma once

#include <QObject>

class OperationListModel;

class ClipboardController : public QObject {
  Q_OBJECT

public:
  explicit ClipboardController(QObject *parent = nullptr);

  // Set reference to OperationListModel (for getting selected operations)
  void setOperationModel(OperationListModel *model);

  // Copy selected operations to system clipboard as CSV
  Q_INVOKABLE void copySelectedOperations() const;

private:
  OperationListModel *_operationModel = nullptr;
};
