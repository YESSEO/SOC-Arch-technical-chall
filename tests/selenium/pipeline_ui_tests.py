"""Selenium Script used for verifying
Wazuh Dashboard
Wazuh API health Check
"""
from os import getenv
import sys
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

class SeleniumTest:
    """Selenium & API some Test for Wazuh Dashboard, API health Check"""

    def __init__(self, driver_path):
        self.wazuh_url =  getenv("WAZUH_URL")
        self.wazuh_user = getenv("WAZUH_USER")
        self.wazuh_pass = getenv("WAZUH_PASS")
        if not all([self.wazuh_url, self.wazuh_user, self.wazuh_pass]):
            print("Missing env variables ..")
            sys.exit(1)

        # Init Drivers
        options = Options()
        options.add_argument("--headless")       # run without GUI
        options.add_argument("--no-sandbox")     # raw CPU ran
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--ignore-certificate-errors")

        self.driver = webdriver.Chrome(service=Service(driver_path), options=options)

    def test_login_form_present(self, timeout=10) -> bool:
        """Verify the login form exists and page title is correct"""

        self.driver.get(self.wazuh_url)
        # Check Title
        title = self.driver.title
        if "Wazuh" not in title:
            print("Wazuh title not detected")
            sys.exit(0)

        # Wait till the form is available
        try:
            element = WebDriverWait(self.driver, 20).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "[class='euiForm']"))
            )
            print(element)

        except TimeoutException:
            print("couldnt not find login")
            return False

    def test_programamtic_login(self) -> bool:
        """User credentials to login and verify Dashboard"""
    def test_api_health(self):
        """Verify Wazuh api health check"""


    def test_api_version(self):
        """Grabe api version"""
def main():
    """ This global function to init the Test"""

    test = SeleniumTest("/usr/bin/chromedriver")
    if test.test_login_form_present() :
        test.test_programamtic_login()


if __name__ == '__main__':
    main()
