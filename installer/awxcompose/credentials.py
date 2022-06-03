DATABASES = {
    'default': {
        'ATOMIC_REQUESTS': True,
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': "awx",
        'USER': "awx",
        'PASSWORD': "awxpass",
        'HOST': "postgres",
        'PORT': "5432",
    }
}

BROADCAST_WEBSOCKET_SECRET = "NElVd1JTd2dNTzNxMWVwRGNsZnp2cWJDLDYyQjU0enZqSnV0TlJzSUF0VzpITSxXc2xOLHh6SHRyUzVYOlpXRnlmZlMud0gydm5YZk9GMTZSQ3pUMEt3NWpmOm5LN290LE9mVGxrbk1LOmNqQkxaejpWV0MxZ003MDpIekNwM2M="
