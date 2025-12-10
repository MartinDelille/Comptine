#include <QClipboard>
#include <QGuiApplication>
#include "ClipboardController.h"
#include "OperationListModel.h"

ClipboardController::ClipboardController(QObject *parent) : QObject(parent) {
}

void ClipboardController::setOperationModel(OperationListModel *model) {
  _operationModel = model;
}

void ClipboardController::copySelectedOperations() const {
  if (!_operationModel) return;

  QString csv = _operationModel->selectedOperationsAsCsv();
  if (!csv.isEmpty()) {
    QGuiApplication::clipboard()->setText(csv);
  }
}
