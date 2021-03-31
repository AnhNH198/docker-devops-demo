from django.test import TestCase, client
from django.contrib.auth import get_user_model
from django.urls import reverse

"""Import the test the client that will allow to make test requests to
 application in unit test"""


class AdminSiteTest(TestCase):
    def setUp(self):
        """Create setup function
        that run before every test that we run"""
        # Create test client
        # Add new user, make sure the user is logged into client
        """Create regular user that is not authenticated which can be 
        list in admin page"""