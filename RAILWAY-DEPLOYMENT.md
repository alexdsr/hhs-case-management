# Railway Deployment Guide — HHS Case Management (Java 17)

## Prerequisites

- GitHub account
- Railway account (free at railway.app) — sign in with GitHub

---

## Step 1 — Push to GitHub

From the project root (where `pom.xml` lives):

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/hhs-case-management.git
git push -u origin main
```

---

## Step 2 — Create a Railway Project

1. Go to **https://railway.app** and sign in
2. Click **New Project**
3. Choose **Deploy from GitHub repo**
4. Select **hhs-case-management** from the list
5. Railway detects the `Dockerfile` automatically — click **Deploy Now**

---

## Step 3 — Configure the Port

Railway injects a `$PORT` environment variable. WildFly needs to bind to it.

1. In your Railway project, click the service tile
2. Go to **Variables** tab
3. Add this variable:

| Name | Value |
|------|-------|
| `PORT` | `8080` |

> Railway routes external traffic to whatever port you specify here.
> WildFly is already configured to bind to `0.0.0.0:8080` in the Dockerfile.

---

## Step 4 — Generate a Public URL

1. Go to the **Settings** tab of your service
2. Under **Networking**, click **Generate Domain**
3. Railway gives you a URL like `hhs-case-management.up.railway.app`

---

## Step 5 — Wait for Deployment

The first deploy takes **5–8 minutes** because Railway must:
- Pull the Maven build image (~600MB)
- Download all Maven dependencies (~200MB)
- Pull WildFly 31 image (~500MB)
- Build your WAR
- Start WildFly (30–45 seconds)

Subsequent deploys are faster because Docker layers are cached.

---

## Step 6 — Access the App

Once the health check passes, open:

```
https://YOUR-APP.up.railway.app/hhs-case-management/
```

### Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Administrator | admin@hhs.gov | Admin1234! |
| Caseworker | caseworker@hhs.gov | Case1234! |

---

## Important Notes

### Data Resets on Restart
The app uses an H2 file-based database stored inside the container at
`/opt/jboss/hhsdb/hhsdb.mv.db`. If the container restarts, all data entered
since startup is lost and the seed data is restored. This is expected for a demo.

### Free Tier Limits
Railway's free tier includes $5/month of usage credit. WildFly is memory-hungry
(~512MB RAM). Monitor usage in the Railway dashboard under **Metrics**.

### Cold Starts
If the service is inactive, Railway may sleep it. The next request triggers a
cold start (~30–45 seconds for WildFly to boot). This is normal on free tier.

### Logs
View real-time logs in Railway's dashboard under the **Logs** tab. WildFly
startup logs confirm when the datasource is registered and the WAR is deployed.

---

## Troubleshooting

**Health check fails / app not reachable**
- Check Logs tab — WildFly takes 25–45 seconds to fully start
- Verify the datasource CLI ran successfully (look for "HHSDataSource" in logs)
- Try increasing the healthcheck timeout in `railway.json` to 180

**OutOfMemoryError**
- Upgrade Railway plan or add JVM flags to the Dockerfile CMD:
  `-Xms256m -Xmx512m`

**WAR not deploying**
- Look for `WFLYDR0001` in logs — indicates a deployment error
- Most common cause: missing datasource. Check CLI script ran successfully.

---

## Re-deploying After Code Changes

Just push to GitHub:

```bash
git add .
git commit -m "Your changes"
git push
```

Railway detects the push and re-deploys automatically.
