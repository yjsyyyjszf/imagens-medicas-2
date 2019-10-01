import pytest

from django.test import RequestFactory
from django.urls import reverse
from im2webapp.views import ImageEditorLiteView, ImageListView
from django.contrib.auth.models import User, AnonymousUser
from mixer.backend.django import mixer


@pytest.mark.django_db
class TestViews:
    def test_lite_editor(self):
        path = reverse('lite-editor')
        request = RequestFactory().get(path)
        view_instance = ImageEditorLiteView.as_view()
        response = view_instance(request)
        assert response.status_code == 200

    def test_images_list_authenticated(self):
        path = reverse('images_list')
        request = RequestFactory().get(path)
        request.user = mixer.blend(User)
        view_instance = ImageListView.as_view()
        response = view_instance(request)
        assert response.status_code == 200

    def test_images_list_unauthenticated(self):
        path = reverse('images_list')
        request = RequestFactory().get(path)
        request.user = AnonymousUser()
        view_instance = ImageListView.as_view()
        response = view_instance(request)
        assert response.status_code == 302
        assert reverse('login') in response.url