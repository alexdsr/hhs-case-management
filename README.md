# HHS Client Intake & Case Management System

A Jakarta EE 10 web application demonstrating enterprise-grade client intake and
case management for the Utah Division of Health & Human Services.

Built as a portfolio demonstration using:

- **Jakarta Faces 4.0 (JSF)** — component-based UI layer
- **Enterprise JavaBeans (EJB 4.0)** — stateless session beans for business logic
- **JPA 3.1 + JPQL** — data persistence with named queries
- **CDI 4.0** — dependency injection and session management
- **H2 (in-memory)** — zero-config database for demo purposes
- **WildFly 31** — Jakarta EE 10 compliant application server
- **WCAG 2.1 AA** — accessible markup throughout

---

## Features

### Public Portal
- Citizen service application intake form
- Supports Medicaid, SNAP, housing, disability, mental health, and other service types
- WCAG 2.1 AA compliant — skip navigation, proper labels, sufficient color contrast
- Confirmation page with case reference number

### Staff Portal (login required)
- Role-based access: **Admin** and **Caseworker** roles
- Dashboard with case status summary tiles and filterable case queue
- Case detail view: client information, status management, caseworker assignment
- Case notes — full audit trail of caseworker activity
- Session timeout and authentication filter protecting all staff pages

---

## Prerequisites

| Tool | Version |
|------|---------|
| Java (JDK) | 17 or later |
| Maven | 3.9+ |
| WildFly | 31.0.0.Final |
| IntelliJ IDEA | 2023.1+ (Ultimate recommended) |

---

## Running the Application

### Option 1 — WildFly Maven Plugin (easiest)

```bash
# Download and provision WildFly, then deploy the app
mvn wildfly:run
```

The plugin downloads WildFly automatically on first run. The app will be
available at:

```
http://localhost:8080/hhs-case-management/
```

### Option 2 — Deploy to existing WildFly instance

1. Download WildFly 31 from https://www.wildfly.org/downloads/
2. Start WildFly:
   ```bash
   $WILDFLY_HOME/bin/standalone.sh        # macOS / Linux
   $WILDFLY_HOME\bin\standalone.bat       # Windows
   ```
3. Build and deploy:
   ```bash
   mvn clean package wildfly:deploy
   ```

---

## Importing into IntelliJ IDEA

1. Open IntelliJ IDEA
2. Choose **File → Open** and select the `hhs-case-management` folder
3. IntelliJ detects the `pom.xml` automatically — click **Open as Project**
4. Wait for Maven to download dependencies (first run only)
5. To run directly from IntelliJ:
   - Go to **Run → Edit Configurations**
   - Add a new **Maven** run configuration
   - Set the working directory to the project root
   - Set the command to: `wildfly:run`
   - Click **Run**

> **IntelliJ Ultimate** users can also configure a WildFly application server
> under **Run → Edit Configurations → + → JBoss/WildFly Server → Local**
> and deploy the WAR artifact directly for hot-reload support.

---

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Administrator | admin@hhs.gov | Admin1234! |
| Caseworker | caseworker@hhs.gov | Case1234! |

> These credentials are for demonstration only. Remove the credentials notice
> from `login.xhtml` before any production deployment.

---

## Project Structure

```
hhs-case-management/
├── pom.xml
└── src/main/
    ├── java/gov/state/hhs/
    │   ├── model/              # JPA entities (User, Client, ServiceApplication, CaseNote)
    │   ├── model/              # Enums (UserRole, ServiceType, ApplicationStatus, Priority)
    │   ├── repository/         # Data access via JPQL named queries
    │   ├── service/            # EJB stateless session beans
    │   ├── backing/            # JSF CDI backing beans
    │   └── auth/               # Session bean and authentication filter
    ├── resources/META-INF/
    │   ├── persistence.xml     # JPA configuration
    │   └── seed-data.sql       # Demo data loaded on startup
    └── webapp/
        ├── WEB-INF/
        │   ├── templates/
        │   │   └── layout.xhtml    # Shared Facelets template
        │   ├── faces-config.xml
        │   ├── web.xml
        │   └── beans.xml
        ├── public/
        │   ├── index.xhtml         # Citizen intake form
        │   └── confirmation.xhtml  # Submission confirmation
        ├── staff/
        │   ├── dashboard.xhtml     # Staff case queue + summary
        │   └── case-detail.xhtml   # Case view, assignment, notes
        ├── login.xhtml
        └── resources/css/
            └── main.css            # WCAG 2.1 AA compliant stylesheet
```

---

## Accessibility (WCAG 2.1 AA)

This application is built to meet WCAG 2.1 Level AA:

- **1.1.1** — All meaningful images have alt text
- **1.3.1** — Form labels programmatically associated with inputs
- **1.4.3** — Color contrast ratios meet 4.5:1 minimum for normal text
- **2.4.1** — Skip navigation link to bypass header
- **2.4.2** — Each page has a descriptive title
- **2.4.6** — Headings and labels describe topic/purpose
- **3.3.1** — Error messages identify the field and describe the error
- **3.3.2** — Labels and instructions present for all form inputs
- **4.1.3** — Status messages use `role="status"` and `aria-live`

---

## Security Notes

This is a **demonstration application**. Before production deployment:

1. Replace H2 with Oracle, PostgreSQL, or another production database
2. Replace SHA-256 password hashing with bcrypt (e.g., jBCrypt library)
3. Enable HTTPS and set `<secure>true</secure>` on session cookies
4. Change `jakarta.faces.PROJECT_STAGE` to `Production` in `web.xml`
5. Remove the demo credentials notice from `login.xhtml`
6. Integrate with your agency's LDAP / Active Directory for authentication
7. Add CSRF token configuration appropriate for your WildFly version

---

## License

Demonstration project — not licensed for production government use without
appropriate security review and compliance certification.
