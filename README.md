# save_app

A Flutter application repository.

## Docker containerization

This project includes a Docker setup to build and serve the Flutter web version, so anyone can clone the repository and run it without installing Flutter locally.

### Build the Docker image

```bash
cd C:\Users\x\save_app
docker build -t save_app_web .
```

### Run the app in Docker

```bash
docker run --rm -p 8080:80 save_app_web
```

Then open:

```text
http://localhost:8080
```

### Alternative with Docker Compose

```bash
docker compose up --build
```

### Notes

- The Docker image builds the Flutter web version and serves it with nginx.
- For mobile or desktop deployment, a local Flutter environment is still required.
- If you want to update the container after changes, rebuild with:

```bash
docker compose up --build
```

