# --- Build Stage ---
FROM golang:1.24-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files to download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the Go application
# CGO_ENABLED=0 is used to build a statically linked binary
# -o /app/main specifies the output file name and location
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/main ./cmd/main.go

# --- Final Stage ---
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the built binary from the build stage
COPY --from=build /app/main .

# Copy the .env.example file
COPY .env.example .

# Expose the port the application runs on
EXPOSE 8080

# Command to run the application
CMD ["./main"]
