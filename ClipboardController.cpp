#include "ClipboardController.h"
#include <QClipboard>
#include <QGuiApplication>

#include "OperationListModel.h"

ClipboardController::ClipboardController(QObject* parent) : QObject(parent) {
}

void ClipboardController::setOperationModel(OperationListModel* model) {
  _operationModel = model;
}

void ClipboardController::copySelectedOperations() const {
  if (!_operationModel) return;

  QString csv = _operationModel->selectedOperationsAsCsv();
  if (!csv.isEmpty()) {
    QGuiApplication::clipboard()->setText(csv);
  }
}
