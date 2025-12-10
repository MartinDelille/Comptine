#pragma once

#include <QObject>
#include "PropertyMacros.h"

class BudgetData;
class CategoryController;

class NavigationController : public QObject {
  Q_OBJECT

  // Tab navigation
  PROPERTY_RW(int, currentTabIndex, 0)

  // Budget month/year navigation
  PROPERTY_RW(int, budgetYear, 0)
  PROPERTY_RW(int, budgetMonth, 0)

  // Category navigation
  PROPERTY_RW(int, currentCategoryIndex, 0)

  // Operation navigation
  PROPERTY_RW(int, currentOperationIndex, 0)

  // Account navigation (custom setter to update operation model)
  PROPERTY_RW_CUSTOM(int, currentAccountIndex, -1)

public:
  explicit NavigationController(QObject *parent = nullptr);

  // Set references to other controllers
  void setBudgetData(BudgetData *budgetData);
  void setCategoryController(CategoryController *categoryController);

  // Month navigation
  Q_INVOKABLE void previousMonth();
  Q_INVOKABLE void nextMonth();

  // Category navigation
  Q_INVOKABLE void previousCategory();
  Q_INVOKABLE void nextCategory();

  // Operation navigation
  Q_INVOKABLE void previousOperation(bool extendSelection = false);
  Q_INVOKABLE void nextOperation(bool extendSelection = false);

  // Tab shortcuts
  Q_INVOKABLE void showOperationsTab();
  Q_INVOKABLE void showBudgetTab();

  // Cross-navigation (switch account and select operation)
  Q_INVOKABLE void selectOperation(const QString &accountName, const QDate &date,
                                   const QString &description, double amount);

public slots:
  // Called when FileController loads navigation state from a file
  void onNavigationStateLoaded(int tabIndex, int budgetYear, int budgetMonth,
                               int accountIndex, int categoryIndex, int operationIndex);

signals:
  void operationSelected(int index);  // Emitted when an operation is selected via selectOperation()

private:
  BudgetData *_budgetData = nullptr;
  CategoryController *_categoryController = nullptr;
};
