#!/bin/bash
set -e
PASS=true
ERRORS=""

for F in query_error_rate query_p99 query_deriv query_predict; do
  if [ ! -f ~/${F}.txt ]; then
    ERRORS="${ERRORS}~/${F}.txt not found.\n"; PASS=false
  fi
done

if [ -f ~/query_error_rate.txt ]; then
  Q=$(cat ~/query_error_rate.txt | tr -d '[:space:]')
  if ! echo "$Q" | grep -qi "rate.*http_requests_total.*5"; then
    ERRORS="${ERRORS}Error rate query should use rate() on http_requests_total with status filter.\n"; PASS=false
  fi
fi

if [ -f ~/query_p99.txt ]; then
  Q=$(cat ~/query_p99.txt | tr -d '[:space:]')
  if ! echo "$Q" | grep -qi "histogram_quantile.*0.99"; then
    ERRORS="${ERRORS}P99 query should use histogram_quantile(0.99, ...).\n"; PASS=false
  fi
fi

if [ -f ~/query_deriv.txt ]; then
  Q=$(cat ~/query_deriv.txt | tr -d '[:space:]')
  if ! echo "$Q" | grep -qi "deriv"; then
    ERRORS="${ERRORS}Derivative query should use deriv().\n"; PASS=false
  fi
fi

if [ -f ~/query_predict.txt ]; then
  Q=$(cat ~/query_predict.txt | tr -d '[:space:]')
  if ! echo "$Q" | grep -qi "predict_linear"; then
    ERRORS="${ERRORS}Prediction query should use predict_linear().\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: All PromQL queries are correct!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
