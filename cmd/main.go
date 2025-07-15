package main

import (
	"baas-project-api/internal/configs"
	"baas-project-api/internal/i3s"
	"baas-project-api/internal/router"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/schema"
)

func main() {
	config := configs.LoadConfig()

	//////////// Init Gorm Database //////////
	db, err := gorm.Open(postgres.Open(config.DatabaseURL), &gorm.Config{
		NamingStrategy: schema.NamingStrategy{
			SingularTable: false,
			NoLowerCase:   false,
		},
	})
	if err != nil {
		panic(err)
	}

	// TEMP
	_ = db

	//////////// Migrate I3S Schema //////////
	i3s := i3s.NewI3S(config)
	if err := i3s.Migrate(); err != nil {
		log.Fatalf("failed to migrate database: %v\n", err)
	}

	//////////// Init Cache //////////
	// cache := cache.New(15*time.Minute, 20*time.Minute)

	//////////// Init Repo, Service //////////
	// Repositories
	// projectRepo := repo.NewProjectRepository(db)
	// entityRepo := repo.NewEntityRepository(db, cache)
	// userRepo := repo.NewUserRepository(db, cache)
	// Services

	//////////// Init Controllers //////////

	cli := router.NewApiCli(config)

	cli.Run()
}
