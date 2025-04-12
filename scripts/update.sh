#!/bin/bash
INFOGREP_CHART_DIR="./infogrep-charts"

helm upgrade -i infogrep -f config.yaml ${INFOGREP_CHART_DIR} --create-namespace
