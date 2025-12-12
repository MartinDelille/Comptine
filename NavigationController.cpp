#include <QDate>

#include "Account.h"
#include "BudgetData.h"
#include "CategoryController.h"
#include "NavigationController.h"

NavigationController::NavigationController(QObject* parent) : QObject(parent) {
  // Initialize budget date to current month (will be overridden when a file is loaded)
  QDate today = QDate::currentDate();
  _budgetYear = today.year();
  _budgetMonth = today.month();
}

void NavigationController::setCategoryController(CategoryController* categoryController) {
  _categoryController = categoryController;
}

void NavigationController::setBudgetData(BudgetData* budgetData) {
  _budgetData = budgetData;
}

Account* NavigationController::currentAccount() const {
  if (!_budgetData) return nullptr;
  return _budgetData->getAccount(_currentAccountIndex);
}

int NavigationController::currentAccountIndex() const {
  return _currentAccountIndex;
}

void NavigationController::set_currentAccountIndex(int index) {
  if (!_budgetData) return;

  int accountCount = _budgetData->accountCount();
  if (index >= -1 && index < accountCount) {
    bool changed = (index != _currentAccountIndex);
    _currentAccountIndex = index;
    // Always update the operation model with the current account pointer
    // (the model has its own guard to avoid unnecessary resets)
    _budgetData->operationModel()->setAccount(_budgetData->getAccount(index));

    if (changed) {
      emit currentAccountIndexChanged();
      emit currentAccountChanged();
    }
  }
}

void NavigationController::previousMonth() {
  if (_budgetMonth == 1) {
    set_budgetMonth(12);
    set_budgetYear(_budgetYear - 1);
  } else {
    set_budgetMonth(_budgetMonth - 1);
  }
}

void NavigationController::nextMonth() {
  if (_budgetMonth == 12) {
    set_budgetMonth(1);
    set_budgetYear(_budgetYear + 1);
  } else {
    set_budgetMonth(_budgetMonth + 1);
  }
}

void NavigationController::previousCategory() {
  if (!_categoryController) return;

  QVariantList summary = _categoryController->monthlyBudgetSummary(_budgetYear, _budgetMonth);
  if (_currentCategoryIndex > 0) {
    set_currentCategoryIndex(_currentCategoryIndex - 1);
  }
}

void NavigationController::nextCategory() {
  if (!_categoryController) return;

  QVariantList summary = _categoryController->monthlyBudgetSummary(_budgetYear, _budgetMonth);
  if (_currentCategoryIndex < summary.size() - 1) {
    set_currentCategoryIndex(_currentCategoryIndex + 1);
  }
}

void NavigationController::previousOperation(bool extendSelection) {
  if (!_budgetData) return;

  Account* account = currentAccount();
  if (!account) return;

  int currentIndex = account->currentOperationIndex();
  if (currentIndex > 0) {
    account->set_currentOperationIndex(currentIndex - 1);
    _budgetData->operationModel()->select(account->currentOperationIndex(), extendSelection);
  }
}

void NavigationController::nextOperation(bool extendSelection) {
  if (!_budgetData) return;

  Account* account = currentAccount();
  if (!account) return;

  int currentIndex = account->currentOperationIndex();
  if (currentIndex < account->operationCount() - 1) {
    account->set_currentOperationIndex(currentIndex + 1);
    _budgetData->operationModel()->select(account->currentOperationIndex(), extendSelection);
  }
}

void NavigationController::showOperationsTab() {
  set_currentTabIndex(0);
}

void NavigationController::showBudgetTab() {
  set_currentTabIndex(1);
}

void NavigationController::navigateToOperation(const QString& accountName, const QDate& date,
                                               const QString& description, double amount) {
  if (!_budgetData) return;

  // Find the account index
  int accountIndex = -1;
  QList<Account*> accounts = _budgetData->accounts();
  for (int i = 0; i < accounts.size(); ++i) {
    if (accounts[i]->name() == accountName) {
      accountIndex = i;
      break;
    }
  }

  if (accountIndex < 0) {
    return;
  }

  // Switch to the account
  set_currentAccountIndex(accountIndex);

  // Find the operation in the account
  Account* account = accounts[accountIndex];
  const QList<Operation*>& ops = account->operations();
  for (int i = 0; i < ops.size(); ++i) {
    Operation* op = ops[i];
    if (op->date() == date && op->description() == description && qFuzzyCompare(op->amount(), amount)) {
      // Set this operation as the current operation for the account
      account->set_currentOperation(op);

      // Select in the model
      _budgetData->operationModel()->select(i);

      // Emit signal so OperationList can focus the operation
      emit operationSelected(i);

      // Switch to Operations tab
      set_currentTabIndex(0);
      return;
    }
  }
}

void NavigationController::onNavigationStateLoaded(int tabIndex, int budgetYear, int budgetMonth,
                                                   int accountIndex, int categoryIndex, int operationIndex) {
  set_currentTabIndex(tabIndex);
  set_budgetYear(budgetYear);
  set_budgetMonth(budgetMonth);
  set_currentAccountIndex(accountIndex);
  set_currentCategoryIndex(categoryIndex);

  // Set the operation index on the current account
  Account* account = currentAccount();
  if (account) {
    account->set_currentOperationIndex(operationIndex);
  }
}
