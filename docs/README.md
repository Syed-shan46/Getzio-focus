# Getzio Focus Privacy Policy Web Project

A premium, App Store-compliant single-page static website for Getzio Focus's privacy policy, hosted directly in the `/docs` folder of the main repository.

## 🚀 How to Enable GitHub Pages

Follow these steps to host this privacy policy website on GitHub Pages for free:

### 1. Enable GitHub Pages in your Repository Settings
1. Go to your repository **`Getzio-focus`** on GitHub.com.
2. Click on the **Settings** tab at the top.
3. On the left sidebar, click on **Pages** (under the "Code and automation" section).
4. Under **Build and deployment** -> **Branch**:
   - Change "None" to **`main`**.
   - Change the folder selection dropdown from `/ (root)` to **`/docs`** (this is the key step to serve it from the `docs/` directory!).
5. Click **Save**.

### 2. Get Your Live URL
GitHub will take about 1 minute to build the site. Once complete, refresh the Pages settings page. You will see a banner at the top saying:
> Your site is live at `https://Syed-shan46.github.io/Getzio-focus/`

Copy this URL and paste it into **App Store Connect** under:
* **App Privacy** -> **Privacy Policy URL**: `https://Syed-shan46.github.io/Getzio-focus/`
* **App Privacy** -> **Terms of Service URL (optional)**: `https://Syed-shan46.github.io/Getzio-focus/#terms`

---

## 🔍 Key Sections Covered for Apple Approval
* **Authentication Data**: Explicitly states how the phone number is collected and validated securely via Firebase Authentication.
* **Task Data Caching**: Highlights that user task information is processed and securely cached locally on the device (Hive DB).
* **Data Deletion Link**: Contains a prominent `mailto:` action so reviewers and users can instantly submit account & data deletion requests (mandatory under App Store guidelines).
* **Contact Information**: Provides direct contact details (`shihadpalakkad@gmail.com`).
