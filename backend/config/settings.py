from pathlib import Path
from datetime import timedelta

import environ

BASE_DIR = Path(__file__).resolve().parent.parent

env = environ.Env(
    DEBUG=(bool, False),
    ALLOWED_HOSTS=(list, []),
    CORS_ALLOWED_ORIGINS=(list, []),
)
environ.Env.read_env(BASE_DIR / ".env")

SECRET_KEY = env("SECRET_KEY", default="unsafe-dev-secret-key-change-me-32chars")
DEBUG = env("DEBUG")
ALLOWED_HOSTS = env("ALLOWED_HOSTS")

CORS_ALLOWED_ORIGINS = env("CORS_ALLOWED_ORIGINS")

THROTTLE_CACHE_URL = env("THROTTLE_CACHE_URL", default="")
THROTTLE_TRUSTED_PROXY_COUNT = env.int("THROTTLE_TRUSTED_PROXY_COUNT", default=0)

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework_simplejwt.token_blacklist',
    'drf_spectacular',
    'corsheaders',
    'users',
    'medical',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'config.middleware.RequestIDMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

DATABASES = {
    "default": env.db("DATABASE_URL", default=f"sqlite:///{BASE_DIR / 'db.sqlite3'}"),
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.Argon2PasswordHasher",
    "django.contrib.auth.hashers.PBKDF2PasswordHasher",
    "django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher",
    "django.contrib.auth.hashers.ScryptPasswordHasher",
]

AUTH_USER_MODEL = "users.User"

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / "staticfiles"

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_THROTTLE_CLASSES": (
        "rest_framework.throttling.AnonRateThrottle",
        "rest_framework.throttling.UserRateThrottle",
    ),
    "DEFAULT_THROTTLE_RATES": {
        "anon": "120/minute",
        "user": "120/minute",
        "auth_register": "5/hour",
        "auth_login": "5/hour",
        "auth_session": "20/hour",
        "ai": "10/hour",
    },
    "NUM_PROXIES": THROTTLE_TRUSTED_PROXY_COUNT,
    "EXCEPTION_HANDLER": "config.exceptions.api_exception_handler",
    "URL_FORMAT_OVERRIDE": None,
}

if THROTTLE_CACHE_URL:
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.redis.RedisCache",
            "LOCATION": THROTTLE_CACHE_URL,
        }
    }
else:
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "medstory-local-cache",
        }
    }

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=15),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=30),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
    "UPDATE_LAST_LOGIN": True,
}

SPECTACULAR_SETTINGS = {
    "TITLE": "MedStory API",
    "DESCRIPTION": "Personal medical memory API.",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
}

CELERY_BROKER_URL = env("CELERY_BROKER_URL", default="redis://localhost:6379/0")
CELERY_RESULT_BACKEND = env("CELERY_RESULT_BACKEND", default=CELERY_BROKER_URL)
CELERY_TASK_ALWAYS_EAGER = env.bool("CELERY_TASK_ALWAYS_EAGER", default=False)
CELERY_BEAT_SCHEDULE = {
    "purge-original-deletion-retries": {
        "task": "medical.tasks.purge_storage_deletions_task",
        "schedule": 300.0,
    },
    "cleanup-transient-originals": {
        "task": "medical.tasks.cleanup_transient_originals_task",
        "schedule": 3600.0,
    },
}

AI_LLM_PROVIDER = env("AI_LLM_PROVIDER", default="mock")
AI_OCR_PROVIDER = env("AI_OCR_PROVIDER", default="mock")
AI_STT_PROVIDER = env("AI_STT_PROVIDER", default="mock")
AI_OPENAI_API_KEY = env("AI_OPENAI_API_KEY", default="")
AI_OPENAI_MODEL = env("AI_OPENAI_MODEL", default="gpt-5.1-mini")
# Visit preparation benefits from stronger synthesis than high-volume document
# extraction. Keep the fallback equal to the general model so existing deployments
# do not change behavior until they opt in.
AI_OPENAI_SUMMARY_MODEL = env("AI_OPENAI_SUMMARY_MODEL", default=AI_OPENAI_MODEL)
AI_OPENAI_OCR_MODEL = env("AI_OPENAI_OCR_MODEL", default=AI_OPENAI_MODEL)
AI_OPENAI_STT_MODEL = env("AI_OPENAI_STT_MODEL", default="gpt-4o-mini-transcribe")
AI_OPENAI_TIMEOUT_SECONDS = env.int("AI_OPENAI_TIMEOUT_SECONDS", default=60)

ORIGINAL_STORAGE_BACKEND = env("ORIGINAL_STORAGE_BACKEND", default="memory")
ORIGINAL_STORAGE_SERVICE_ROLE = env("ORIGINAL_STORAGE_SERVICE_ROLE", default="all")
ORIGINAL_STORAGE_REQUIRE_S3 = env.bool(
    "ORIGINAL_STORAGE_REQUIRE_S3",
    default=not DEBUG,
)
ORIGINAL_STORAGE_ENDPOINT = env("ORIGINAL_STORAGE_ENDPOINT", default="http://garage:3900")
ORIGINAL_STORAGE_REGION = env("ORIGINAL_STORAGE_REGION", default="medstory")
ORIGINAL_STORAGE_BUCKET = env("ORIGINAL_STORAGE_BUCKET", default="medstory-originals")
ORIGINAL_STORAGE_ACCESS_KEY_FILE = env("ORIGINAL_STORAGE_ACCESS_KEY_FILE", default="")
ORIGINAL_STORAGE_SECRET_KEY_FILE = env("ORIGINAL_STORAGE_SECRET_KEY_FILE", default="")
ORIGINAL_STORAGE_ACCESS_KEY = env("ORIGINAL_STORAGE_ACCESS_KEY", default="")
ORIGINAL_STORAGE_SECRET_KEY = env("ORIGINAL_STORAGE_SECRET_KEY", default="")
ORIGINAL_STORAGE_UPLOAD_ACCESS_KEY_FILE = env(
    "ORIGINAL_STORAGE_UPLOAD_ACCESS_KEY_FILE",
    default=ORIGINAL_STORAGE_ACCESS_KEY_FILE,
)
ORIGINAL_STORAGE_UPLOAD_SECRET_KEY_FILE = env(
    "ORIGINAL_STORAGE_UPLOAD_SECRET_KEY_FILE",
    default=ORIGINAL_STORAGE_SECRET_KEY_FILE,
)
ORIGINAL_STORAGE_UPLOAD_ACCESS_KEY = env(
    "ORIGINAL_STORAGE_UPLOAD_ACCESS_KEY",
    default=ORIGINAL_STORAGE_ACCESS_KEY,
)
ORIGINAL_STORAGE_UPLOAD_SECRET_KEY = env(
    "ORIGINAL_STORAGE_UPLOAD_SECRET_KEY",
    default=ORIGINAL_STORAGE_SECRET_KEY,
)
ORIGINAL_STORAGE_READ_ACCESS_KEY_FILE = env(
    "ORIGINAL_STORAGE_READ_ACCESS_KEY_FILE",
    default=ORIGINAL_STORAGE_ACCESS_KEY_FILE,
)
ORIGINAL_STORAGE_READ_SECRET_KEY_FILE = env(
    "ORIGINAL_STORAGE_READ_SECRET_KEY_FILE",
    default=ORIGINAL_STORAGE_SECRET_KEY_FILE,
)
ORIGINAL_STORAGE_READ_ACCESS_KEY = env(
    "ORIGINAL_STORAGE_READ_ACCESS_KEY",
    default=ORIGINAL_STORAGE_ACCESS_KEY,
)
ORIGINAL_STORAGE_READ_SECRET_KEY = env(
    "ORIGINAL_STORAGE_READ_SECRET_KEY",
    default=ORIGINAL_STORAGE_SECRET_KEY,
)
ORIGINAL_STORAGE_PROCESSING_ACCESS_KEY_FILE = env(
    "ORIGINAL_STORAGE_PROCESSING_ACCESS_KEY_FILE",
    default=ORIGINAL_STORAGE_ACCESS_KEY_FILE,
)
ORIGINAL_STORAGE_PROCESSING_SECRET_KEY_FILE = env(
    "ORIGINAL_STORAGE_PROCESSING_SECRET_KEY_FILE",
    default=ORIGINAL_STORAGE_SECRET_KEY_FILE,
)
ORIGINAL_STORAGE_PROCESSING_ACCESS_KEY = env(
    "ORIGINAL_STORAGE_PROCESSING_ACCESS_KEY",
    default=ORIGINAL_STORAGE_ACCESS_KEY,
)
ORIGINAL_STORAGE_PROCESSING_SECRET_KEY = env(
    "ORIGINAL_STORAGE_PROCESSING_SECRET_KEY",
    default=ORIGINAL_STORAGE_SECRET_KEY,
)
ORIGINAL_STORAGE_DELETION_ACCESS_KEY_FILE = env(
    "ORIGINAL_STORAGE_DELETION_ACCESS_KEY_FILE",
    default=ORIGINAL_STORAGE_ACCESS_KEY_FILE,
)
ORIGINAL_STORAGE_DELETION_SECRET_KEY_FILE = env(
    "ORIGINAL_STORAGE_DELETION_SECRET_KEY_FILE",
    default=ORIGINAL_STORAGE_SECRET_KEY_FILE,
)
ORIGINAL_STORAGE_DELETION_ACCESS_KEY = env(
    "ORIGINAL_STORAGE_DELETION_ACCESS_KEY",
    default=ORIGINAL_STORAGE_ACCESS_KEY,
)
ORIGINAL_STORAGE_DELETION_SECRET_KEY = env(
    "ORIGINAL_STORAGE_DELETION_SECRET_KEY",
    default=ORIGINAL_STORAGE_SECRET_KEY,
)
ORIGINAL_STORAGE_VERIFY_TLS = env.bool("ORIGINAL_STORAGE_VERIFY_TLS", default=True)
ORIGINAL_STORAGE_CA_BUNDLE = env("ORIGINAL_STORAGE_CA_BUNDLE", default="")
ORIGINAL_MASTER_KEY_FILE = env("ORIGINAL_MASTER_KEY_FILE", default="")
ORIGINAL_MASTER_KEY = env("ORIGINAL_MASTER_KEY", default="")
ORIGINAL_MASTER_KEY_VERSION = env.int("ORIGINAL_MASTER_KEY_VERSION", default=1)
ORIGINAL_STORAGE_QUOTA_BYTES = env.int(
    "ORIGINAL_STORAGE_QUOTA_BYTES",
    default=2 * 1024 * 1024 * 1024,
)
ORIGINAL_STRICT_FILE_VALIDATION = env.bool(
    "ORIGINAL_STRICT_FILE_VALIDATION",
    default=not DEBUG,
)
ORIGINAL_MALWARE_SCANNER = env(
    "ORIGINAL_MALWARE_SCANNER",
    default="mock" if DEBUG else "clamav",
)
CLAMAV_HOST = env("CLAMAV_HOST", default="clamav")
CLAMAV_PORT = env.int("CLAMAV_PORT", default=3310)
CLAMAV_TIMEOUT_SECONDS = env.int("CLAMAV_TIMEOUT_SECONDS", default=30)

DATA_UPLOAD_MAX_MEMORY_SIZE = env.int("DATA_UPLOAD_MAX_MEMORY_SIZE", default=27 * 1024 * 1024)
FILE_UPLOAD_MAX_MEMORY_SIZE = env.int("FILE_UPLOAD_MAX_MEMORY_SIZE", default=1024 * 1024)
FILE_UPLOAD_TEMP_DIR = env("FILE_UPLOAD_TEMP_DIR", default=None)
