# Data Flow Diagrams - Social Live Platform

## Authentication & Authorization Flow

```
┌─────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│ Client  │────▶│ API Gateway  │────▶│ Auth Service │────▶│ Database │
└─────────┘     └──────────────┘     └──────────────┘     └──────────┘
     │                 │                      │                   │
     │                 │                      ▼                   │
     │                 │              ┌──────────────┐            │
     │                 │              │ AML Service  │            │
     │                 │              └──────────────┘            │
     │                 │                      │                   │
     │                 ▼                      ▼                   │
     │          ┌──────────────┐      ┌──────────────┐           │
     └──────────│ JWT Token    │◀─────│ Risk Check   │◀──────────┘
                └──────────────┘      └──────────────┘

Trust Boundary: External → DMZ → Application → Data
```

## KYB Verification Data Flow

```
User Upload → Document Validator → Encryption → State Machine
                                                      │
                                    ┌─────────────────┼─────────────────┐
                                    ▼                 ▼                 ▼
                            External KYB      Manual Review      Audit Log
                                    │                 │                 │
                                    └─────────────────┴─────────────────┘
                                                      ▼
                                            Encrypted Database
```

## Financial Transaction Flow

```
User Request → Commerce Service → AML Screening → Payment Service
                                        │                │
                                        ▼                ▼
                                  Risk Score      External Payment
                                        │                │
                                        └────────┬───────┘
                                                 ▼
                                         Ledger Service
                                                 │
                                    ┌────────────┼────────────┐
                                    ▼            ▼            ▼
                              Debit Entry  Credit Entry  Audit Trail
                                    │            │            │
                                    └────────────┴────────────┘
                                                 ▼
                                          Database (Immutable)
```

## Data Classification

| Data Type | Classification | Encryption | Retention | Access |
|-----------|---------------|------------|-----------|--------|
| Credentials | Critical | AES-256 | Indefinite | Admin+User |
| Financial | Critical | AES-256 | 7 years | Finance+Audit |
| KYB Docs | Critical | AES-256 | 7 years | Compliance |
| PII | High | AES-256 | 2 years | User+Support |
| Transactions | High | AES-256 | 7 years | User+Finance |
| Metadata | Medium | TLS | 1 year | Public |
| Logs | Low | TLS | 90 days | Operations |

## Trust Boundaries

```
┌─────────────────────────────────────────────────────────────┐
│ Internet Zone (Untrusted)                                   │
│   - Public Users                                            │
│   - Potential Attackers                                     │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS Only
┌────────────────────────▼────────────────────────────────────┐
│ DMZ Zone (Filtered)                                         │
│   - WAF (Web Application Firewall)                          │
│   - Load Balancer                                           │
│   - CDN                                                     │
└────────────────────────┬────────────────────────────────────┘
                         │ Authenticated
┌────────────────────────▼────────────────────────────────────┐
│ Application Zone (Trusted)                                  │
│   - API Gateway                                             │
│   - Auth Service                                            │
│   - Business Services                                       │
└────────────────────────┬────────────────────────────────────┘
                         │ Encrypted
┌────────────────────────▼────────────────────────────────────┐
│ Data Zone (Highly Restricted)                               │
│   - PostgreSQL (Encrypted at Rest)                          │
│   - Redis Cache                                             │
│   - File Storage (Encrypted)                                │
└─────────────────────────────────────────────────────────────┘
```

## AML Transaction Monitoring

```
Transaction Event → Business Rules → ML Risk Model → Risk Score
                                                           │
                                        ┌──────────────────┼──────────────────┐
                                        ▼                  ▼                  ▼
                                   Low Risk          Medium Risk         High Risk
                                        │                  │                  │
                                        ▼                  ▼                  ▼
                                   Approve          Manual Review      Block + SAR
                                                                              │
                                                                              ▼
                                                                    Regulatory Report
```

## Data Access Control Matrix

| Service | User Data | Financial | KYB Docs | Logs | Admin |
|---------|-----------|-----------|----------|------|-------|
| User Service | RW | - | - | W | - |
| Commerce | R | RW | - | W | - |
| KYB Service | R | - | RW | W | - |
| AML Service | R | R | R | W | - |
| Admin | R | R | R | R | RW |
| Audit | R | R | R | R | R |

## External Integration Security

```
Internal API ←→ [TLS 1.3] ←→ External Service
      │
      ├─→ Payment Providers (Stripe, PayPal)
      │   └─→ OAuth 2.0 + API Keys
      │
      ├─→ Compliance Services (KYB, AML)
      │   └─→ Encrypted API + Webhooks
      │
      ├─→ Cloud Services (AWS)
      │   └─→ IAM Roles + Encryption
      │
      └─→ Analytics (Monitoring)
          └─→ One-way Data Flow
```

## Backup & Recovery Flow

```
Scheduler → Backup Service → Database Snapshot
                  │                  │
                  ├─→ File Storage ──┘
                  │         │
                  ▼         ▼
              Encryption  Archive
                  │         │
                  └────┬────┘
                       ▼
              Cloud Storage (S3)
                       │
                       ▼
              Integrity Verification
                       │
                ┌──────┴──────┐
                ▼             ▼
            Success       Failure
                │             │
                ▼             ▼
            Log OK      Alert + Retry
```
