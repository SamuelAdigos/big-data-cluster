COMPOSE=docker compose

BASE=-f compose.base.yml
KAFKA=-f compose.kafka.yml
SEAWEEDFS=-f compose.seaweedfs.yml
NIFI=-f compose.nifi.yml

.PHONY: help up-base up-kafka up-seaweedfs up-nifi up-all down down-v ps logs-kafka logs-ui logs-nifi logs-notebook reset-checkpoints reset-kafka-topics

help:
	@echo "Comandos dispoñibles:"
	@echo "  make up-base        -> core (hdfs/yarn/spark-history/notebook)"
	@echo "  make up-kafka       -> base + kafka (+ kafka ui)"
	@echo "  make up-seaweedfs   -> base + seaweedfs (s3)"
	@echo "  make up-nifi        -> base + seaweedfs + nifi"
	@echo "  make up-all         -> base + kafka + seaweedfs + nifi"
	@echo "  make down           -> para contedores (mantén volumes)"
	@echo "  make down-v         -> para e elimina volumes (reset total)"
	@echo "  make ps             -> estado"
	@echo "  make logs-kafka     -> logs kafka"
	@echo "  make logs-ui        -> logs kafka-ui"
	@echo "  make logs-nifi      -> logs nifi"
	@echo "  make logs-notebook  -> logs notebook"
	@echo "  make reset-checkpoints -> borra checkpoints locais (seguro)"
	@echo "  make reset-kafka-topics -> borra topics de prácticas (coidado)"

up-base:
	$(COMPOSE) $(BASE) up -d

up-kafka:
	$(COMPOSE) $(BASE) $(KAFKA) up -d

up-seaweedfs:
	$(COMPOSE) $(BASE) $(SEAWEEDFS) up -d

up-nifi:
	$(COMPOSE) $(BASE) $(SEAWEEDFS) $(NIFI) up -d

up-all:
	$(COMPOSE) $(BASE) $(KAFKA) $(SEAWEEDFS) $(NIFI) up -d

down:
	$(COMPOSE) $(BASE) down

down-v:
	$(COMPOSE) $(BASE) down -v

ps:
	$(COMPOSE) $(BASE) ps

logs-kafka:
	$(COMPOSE) $(BASE) $(KAFKA) logs -f kafka

logs-ui:
	$(COMPOSE) $(BASE) $(KAFKA) logs -f redpanda-console

logs-nifi:
	$(COMPOSE) $(BASE) $(SEAWEEDFS) $(NIFI) logs -f nifi

logs-notebook:
	$(COMPOSE) $(BASE) logs -f notebook

reset-checkpoints:
	@bash ./scripts/reset-checkpoints.sh

reset-kafka-topics:
	@bash ./scripts/reset-kafka-topics.sh
