
# API Issues

## Current Bugs with Taxes

### 1. No Rate Limit Check
- **What:** API accepts any tax rate value
- **Example:** Rate = 1000% → Creates successfully
- **Should:** Reject with HTTP 400

[![API Issues](https://img.shields.io/badge/known_issues-1_reported-orange)]()

### 2. No Empty Label Check  
- **What:** API accepts empty tax names
- **Example:** Label = "" → Creates successfully
- **Should:** Reject with HTTP 400

[![API Issues](https://img.shields.io/badge/known_issues-1_reported-orange)]()

