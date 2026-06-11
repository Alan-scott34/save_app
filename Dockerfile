# Build the Flutter web app
FROM cirrusci/flutter:stable AS builder

WORKDIR /app

# Install dependencies first so rebuilds are faster
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . ./
RUN flutter build web --release

# Serve the built web app with nginx
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
