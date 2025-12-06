#include "Operation.h"

Operation::Operation(QObject *parent) :
    QObject(parent) {}

Operation::Operation(const QDate &date, double amount, const QString &category,
                     const QString &description, QObject *parent) :
    QObject(parent), _date(date), _amount(amount), _category(category), _description(description) {}
