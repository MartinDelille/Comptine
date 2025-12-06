#include "Operation.h"

Operation::Operation(QObject *parent) :
    QObject(parent) {}

Operation::Operation(const QDate &date, double amount, const QString &category,
                     const QString &description, QObject *parent) :
    QObject(parent), _date(date), _amount(amount), _category(category), _description(description) {}

QDate Operation::budgetDate() const {
  // Return explicit budget date if set, otherwise fall back to operation date
  return _budgetDate.isValid() ? _budgetDate : _date;
}

void Operation::set_budgetDate(QDate value) {
  if (_budgetDate != value) {
    _budgetDate = value;
    emit budgetDateChanged();
  }
}
