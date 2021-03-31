from django.test import TestCase
from django.contrib.auth import get_user_model


class ModelTests(TestCase):

    def test_create_user_with_email(self):
        """Test creating new user with email"""
        email = 'boploi@add.com'
        password = 'testing'
        user = get_user_model().objects.create_user(
            email=email,
            password=password
        )
        self.assertEqual(user.email, email)
        self.assertTrue(user.check_password(password))

    def test_new_user_email_normalize(self):
        """Test the email if new user is normalized"""
        email = 'boploi@ADD.COM'
        user = get_user_model().objects.create_user(
            email=email,
            password='testing'
        )
        self.assertEqual(user.email, email.lower())

    def test_new_user_invalid_email(self):
        """Test creating user with no email raises error"""
        with self.assertRaises(ValueError):
            """Everything run below should raise ValueError"""
            get_user_model().objects.create_user(
                email=None,
                password='testing'
            )

    def test_create_super_user(self):
        user = get_user_model().objects.create_superuser(
            'boploi@add.com',
            'testing'
        )

        self.assertTrue(user.is_superuser)
        self.assertTrue(user.is_staff)