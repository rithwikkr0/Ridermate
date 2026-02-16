# Backup & Recovery Plan

## Overview

This document outlines the backup and disaster recovery strategy for RiderMate application, ensuring data protection and business continuity.

## Backup Strategy

### Data Categories

1. **User Data**
   - User profiles
   - Ride history
   - Location memories
   - Friend connections
   - Points and referrals

2. **Application Data**
   - Configuration
   - Feature flags
   - Analytics data

3. **System Data**
   - Application logs
   - Error logs
   - Performance metrics

## Firebase Firestore Backup

### Automatic Backups

1. **Enable Firestore Backups**
   ```bash
   # Using gcloud CLI
   gcloud firestore backups schedules create \
     --database='(default)' \
     --recurrence=daily \
     --retention=7d
   ```

2. **Backup Schedule**
   - **Frequency**: Daily at 2:00 AM UTC
   - **Retention**: 30 days
   - **Location**: Same region as database

### Manual Backups

#### Export Firestore Data
```bash
# Export all collections
gcloud firestore export gs://[BUCKET_NAME] \
  --async

# Export specific collection
gcloud firestore export gs://[BUCKET_NAME] \
  --collection-ids='users,rides,memories' \
  --async
```

#### Backup Script
```bash
#!/bin/bash
# backup-firestore.sh

PROJECT_ID="ridermate-prod"
BUCKET_NAME="ridermate-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="gs://${BUCKET_NAME}/firestore-backup-${TIMESTAMP}"

echo "Starting Firestore backup..."
gcloud firestore export ${BACKUP_PATH} \
  --project=${PROJECT_ID} \
  --async

echo "Backup initiated to ${BACKUP_PATH}"
```

#### Schedule with Cron
```bash
# Add to crontab
0 2 * * * /path/to/backup-firestore.sh >> /var/log/firestore-backup.log 2>&1
```

### Automated Backup via Cloud Scheduler

```bash
# Create Cloud Scheduler job
gcloud scheduler jobs create http firestore-backup \
  --schedule="0 2 * * *" \
  --uri="https://firestore.googleapis.com/v1/projects/[PROJECT_ID]/databases/(default):exportDocuments" \
  --http-method=POST \
  --headers="Content-Type=application/json" \
  --message-body='{"outputUriPrefix":"gs://[BUCKET_NAME]/scheduled-backups"}'
```

## Docker Volume Backup

### Backup Docker Volumes

```bash
#!/bin/bash
# backup-docker-volumes.sh

BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p ${BACKUP_DIR}

# Backup Flutter pub cache
docker run --rm \
  -v flutter-pub-cache:/data \
  -v ${BACKUP_DIR}:/backup \
  ubuntu tar czf /backup/flutter-pub-cache-${TIMESTAMP}.tar.gz -C /data .

echo "Backup completed: ${BACKUP_DIR}/flutter-pub-cache-${TIMESTAMP}.tar.gz"
```

### Restore Docker Volumes

```bash
#!/bin/bash
# restore-docker-volumes.sh

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <backup-file>"
  exit 1
fi

# Restore volume
docker run --rm \
  -v flutter-pub-cache:/data \
  -v $(dirname ${BACKUP_FILE}):/backup \
  ubuntu tar xzf /backup/$(basename ${BACKUP_FILE}) -C /data

echo "Restore completed from ${BACKUP_FILE}"
```

## Application Code Backup

### Git Repository

- **Primary**: GitHub repository
- **Mirrors**: 
  - GitLab (optional)
  - Bitbucket (optional)

### Automated Mirroring

```bash
# .github/workflows/mirror.yml
name: Mirror to GitLab

on:
  push:
    branches: [ main ]

jobs:
  mirror:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Mirror to GitLab
        uses: wearerequired/git-mirror-action@master
        env:
          SSH_PRIVATE_KEY: ${{ secrets.GITLAB_SSH_KEY }}
        with:
          source-repo: "git@github.com:rithwikkr0/Ridermate.git"
          destination-repo: "git@gitlab.com:rithwikkr0/Ridermate.git"
```

## Backup Storage

### Storage Locations

1. **Primary**: Google Cloud Storage
   - Bucket: `ridermate-backups`
   - Region: Same as production
   - Storage class: Standard

2. **Secondary**: AWS S3
   - Bucket: `ridermate-backups-secondary`
   - Region: Different from primary
   - Storage class: Standard

### Backup Retention Policy

| Backup Type | Retention Period | Frequency |
|-------------|-----------------|-----------|
| Daily backups | 30 days | Daily |
| Weekly backups | 90 days | Weekly |
| Monthly backups | 1 year | Monthly |
| Yearly backups | 7 years | Yearly |

### Lifecycle Policy

```bash
# Set lifecycle policy on GCS bucket
cat > lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "age": 30,
          "matchesPrefix": ["daily/"]
        }
      },
      {
        "action": {"type": "Delete"},
        "condition": {
          "age": 90,
          "matchesPrefix": ["weekly/"]
        }
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {
          "age": 365,
          "matchesPrefix": ["monthly/"]
        }
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://ridermate-backups
```

## Recovery Procedures

### Firestore Recovery

#### Full Database Restore
```bash
# Import from backup
gcloud firestore import gs://[BUCKET_NAME]/firestore-backup-[TIMESTAMP] \
  --project=[PROJECT_ID] \
  --async
```

#### Restore Specific Collection
```bash
gcloud firestore import gs://[BUCKET_NAME]/firestore-backup-[TIMESTAMP] \
  --collection-ids='users' \
  --project=[PROJECT_ID]
```

### Application Recovery

#### Rollback to Previous Version

**Using Docker**:
```bash
# Stop current version
docker stop ridermate

# Pull and run previous version
docker run -d -p 80:80 --name ridermate \
  ghcr.io/rithwikkr0/ridermate:v1.0.0

# Verify
curl http://localhost/health
```

**Using Vercel**:
```bash
# List deployments
vercel ls

# Rollback to previous
vercel rollback [DEPLOYMENT_URL]
```

**Using GitHub Actions**:
1. Go to Actions tab
2. Select deploy workflow
3. Find successful deployment
4. Click "Re-run jobs"

### Data Recovery Scenarios

#### Scenario 1: Accidental Data Deletion

1. **Identify backup point**:
   ```bash
   gsutil ls -r gs://ridermate-backups/
   ```

2. **Restore from backup**:
   ```bash
   gcloud firestore import gs://ridermate-backups/[BACKUP_PATH]
   ```

3. **Verify data**:
   - Check affected collections
   - Verify data integrity
   - Test application functionality

#### Scenario 2: Database Corruption

1. **Stop write operations**:
   - Enable read-only mode
   - Notify users

2. **Assess damage**:
   - Identify corrupted data
   - Determine restore point

3. **Restore from backup**:
   ```bash
   # Restore to temporary database
   gcloud firestore import gs://[BACKUP_PATH] \
     --database='recovery' \
     --async
   ```

4. **Verify and migrate**:
   - Validate restored data
   - Migrate to production
   - Resume operations

#### Scenario 3: Complete System Failure

1. **Deploy to new infrastructure**:
   ```bash
   # Deploy using Docker
   docker run -d -p 80:80 \
     --name ridermate \
     ghcr.io/rithwikkr0/ridermate:latest
   ```

2. **Restore database**:
   ```bash
   gcloud firestore import gs://[LATEST_BACKUP]
   ```

3. **Update DNS**:
   - Point to new infrastructure
   - Verify propagation

4. **Verify and test**:
   - Run smoke tests
   - Verify all features
   - Monitor closely

## Disaster Recovery

### Recovery Time Objective (RTO)

- **Critical Systems**: 1 hour
- **Non-Critical Systems**: 4 hours
- **Full Recovery**: 24 hours

### Recovery Point Objective (RPO)

- **Database**: 24 hours (daily backup)
- **Code**: 0 hours (Git versioned)
- **Configuration**: 1 hour

### Disaster Recovery Plan

#### Phase 1: Assessment (0-15 minutes)

1. Identify the incident
2. Assess impact
3. Activate DR team
4. Communicate status

#### Phase 2: Containment (15-30 minutes)

1. Stop the spread of damage
2. Enable read-only mode if needed
3. Capture evidence/logs
4. Document timeline

#### Phase 3: Recovery (30 minutes - 4 hours)

1. Execute recovery procedures
2. Restore from backups
3. Verify data integrity
4. Test critical functions

#### Phase 4: Restoration (4-24 hours)

1. Restore all services
2. Full system validation
3. Performance testing
4. User communication

#### Phase 5: Post-Incident (24+ hours)

1. Root cause analysis
2. Update documentation
3. Improve procedures
4. Team debrief

### DR Team Roles

| Role | Responsibilities | Contact |
|------|-----------------|---------|
| Incident Commander | Overall coordination | [Name/Contact] |
| Technical Lead | Technical decisions | [Name/Contact] |
| Database Admin | Data recovery | [Name/Contact] |
| DevOps Engineer | Infrastructure | [Name/Contact] |
| Communications | User updates | [Name/Contact] |

## Testing & Validation

### Backup Validation

#### Monthly Backup Tests
```bash
#!/bin/bash
# test-backup-restore.sh

echo "Testing backup restore process..."

# 1. Create test database
gcloud firestore databases create test-recovery \
  --project=[PROJECT_ID] \
  --location=[LOCATION]

# 2. Restore latest backup
LATEST_BACKUP=$(gsutil ls -r gs://ridermate-backups/ | grep -v "/\$" | tail -1)
gcloud firestore import ${LATEST_BACKUP} \
  --database='test-recovery'

# 3. Verify data
# Add verification scripts

# 4. Cleanup
gcloud firestore databases delete test-recovery \
  --project=[PROJECT_ID]

echo "Backup test completed"
```

### DR Drill

**Quarterly DR Drills**:
1. Schedule drill (off-peak hours)
2. Simulate failure scenario
3. Execute recovery procedures
4. Measure RTO/RPO
5. Document findings
6. Update procedures

### Backup Monitoring

```bash
# Monitor backup success
#!/bin/bash
# monitor-backups.sh

BUCKET="gs://ridermate-backups"
TODAY=$(date +%Y%m%d)

# Check if today's backup exists
if gsutil ls ${BUCKET}/*${TODAY}* > /dev/null 2>&1; then
  echo "✅ Backup successful for ${TODAY}"
  exit 0
else
  echo "❌ Backup missing for ${TODAY}"
  # Send alert
  curl -X POST ${SLACK_WEBHOOK} \
    -H 'Content-Type: application/json' \
    -d '{"text":"⚠️ Backup missing for '${TODAY}'"}'
  exit 1
fi
```

## Documentation Backup

### Critical Documentation

Store in multiple locations:
- GitHub repository (primary)
- Google Drive (secondary)
- Local copies (tertiary)

### Documents to Backup
- Deployment guides
- Configuration files
- API documentation
- Runbooks
- DR procedures
- Contact lists
- Credentials (encrypted)

## Cost Optimization

### Storage Costs

1. **Use appropriate storage classes**:
   - Standard: Recent backups (0-30 days)
   - Nearline: Monthly backups (30-90 days)
   - Coldline: Yearly backups (90-365 days)
   - Archive: Long-term retention (365+ days)

2. **Compress backups**:
   ```bash
   # Compress before upload
   tar czf backup.tar.gz /data
   gsutil cp backup.tar.gz gs://bucket/
   ```

3. **Lifecycle policies**: Automatic transition between storage classes

## Compliance

### Data Retention Compliance

- GDPR: Right to be forgotten
- Data sovereignty: Regional backups
- Audit trails: Backup access logs

### Security

- Encryption at rest (default in GCS)
- Encryption in transit (TLS)
- Access control (IAM)
- Audit logging enabled

## Checklist

### Daily
- [ ] Verify daily backup completed
- [ ] Check backup logs for errors
- [ ] Monitor storage usage

### Weekly
- [ ] Review backup retention
- [ ] Check backup integrity
- [ ] Update documentation

### Monthly
- [ ] Test backup restoration
- [ ] Review storage costs
- [ ] Update recovery procedures
- [ ] Audit access logs

### Quarterly
- [ ] Conduct DR drill
- [ ] Review RTO/RPO metrics
- [ ] Update DR team contacts
- [ ] Train new team members

### Annually
- [ ] Full DR exercise
- [ ] Review compliance
- [ ] Update DR plan
- [ ] Audit third-party dependencies

## Support Contacts

- Cloud Provider Support: [Contact]
- Database Admin: [Contact]
- DevOps Team: [Contact]
- Security Team: [Contact]

## Resources

- [Firestore Backup Documentation](https://cloud.google.com/firestore/docs/backups)
- [Docker Volume Backup](https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes)
- [Disaster Recovery Best Practices](https://cloud.google.com/architecture/dr-scenarios-planning-guide)
