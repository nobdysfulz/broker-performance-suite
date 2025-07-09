# 🚀 QUICK START GUIDE

## 1. Extract and Setup (2 minutes)

```bash
# Extract the package
unzip google-cloud-deployment-package_*.zip
cd google-cloud-deployment-package

# Run automated setup
./setup.sh YOUR_PROJECT_ID us-central1
```

## 2. Test Locally (1 minute)

```bash
# Start local development
docker-compose up -d

# Test endpoints
curl http://localhost:5000/api/health
curl http://localhost:3000
```

## 3. Deploy to Google Cloud (5 minutes)

```bash
# Automated deployment
./scripts/deploy.sh YOUR_PROJECT_ID us-central1

# Or manual deployment
./scripts/setup-cloud-sql.sh YOUR_PROJECT_ID
./scripts/setup-iam.sh YOUR_PROJECT_ID
gcloud builds submit --config cloudbuild.yaml
```

## 4. Verify Deployment (1 minute)

```bash
# Get service URL
SERVICE_URL=$(gcloud run services describe my-app --region=us-central1 --format="value(status.url)")

# Test deployed application
curl $SERVICE_URL/api/health
curl $SERVICE_URL
```

## 🆘 Need Help?

- **Issues**: Check `docs/TROUBLESHOOTING.md`
- **Development**: See `docs/DEVELOPMENT.md`
- **Deployment**: Read `docs/DEPLOYMENT.md`
- **Full Guide**: Open `README.md`

## ✅ Success Indicators

- ✅ Local: `curl http://localhost:5000/api/health` returns `{"status":"OK"}`
- ✅ Cloud: Service URL returns your React application
- ✅ Database: Cloud SQL instance is running
- ✅ Secrets: Secret Manager contains credentials

**Total Setup Time: ~10 minutes**
