# big-data-cluster

## finais de liña

O repositorio inclúe un `.gitattributes` que forza finais de liña LF nos ficheiros que se montan ou executan dentro dos contedores (scripts `.sh`, ficheiros compose, configuración de Hadoop/Spark, Dockerfiles), sexa cal sexa a configuración de Git do equipo. Xa non é necesario configurar `core.autocrlf` antes de clonar; se o tiñas en `input`, non pasa nada.

Este repositorio contén un **entorno modular de big data en docker compose** pensado para docencia e probas locais.  
Inclúe un clúster base **hadoop (hdfs + yarn) + spark + jupyterlab**, e módulos opcionais para completar un ecosistema típico de enxeñaría de datos:

- kafka (+ kafka ui)
- seaweedfs (s3)
- apache nifi
- apache airflow
- apache superset


O deseño é incremental: primeiro levántase o clúster base e, segundo as necesidades, actívanse os módulos adicionais.

---

## imaxes docker empregadas

Este proxecto usa varias imaxes personalizadas publicadas en docker hub (todas as que comezan por `adbgonzalez`):

- `adbgonzalez/spark:4.1.1-py312`  
  imaxe base do clúster: hadoop + yarn + spark (inclúe scripts e configuración para executar spark sobre yarn)

- `adbgonzalez/spark-notebook:4.1.1-py312`  
  jupyterlab listo para pyspark, configurado para enviar aplicacións a yarn, con soporte para jars adicionais (`/opt/spark/jars-extra`)

- `adbgonzalez/hadoop:3.4.3-py312`  
  imaxe base para o stack hadoop legado definido en `compose.hadoop.yml`

- `adbgonzalez/airflow:3.1.8`  
  imaxe personalizada de Airflow para este stack, preparada para instalar providers adicionais a través de `airflow/requirements.txt`

- `adbgonzalez/kafka:3.9`  
  kafka en modo kraft (sen zookeeper) cunha configuración simplificada para uso local

> nota: seaweedfs, nifi e superset usan imaxes oficiais (`chrislusf/seaweedfs`, `apache/nifi`, `apache/superset`, etc.).

---

## requisitos

- windows 10/11 ou linux
- docker compose v2
- recomendado: 16 gb ram mínimo (ideal 32 gb)
- espazo en disco: o uso de volumes persistentes (hdfs/kafka/seaweedfs) pode medrar rapidamente

---

## composición modular do clúster

O proxecto está dividido en varios ficheiros compose, para activar só o que se precisa:

- `compose.base.yml` -> clúster base (hdfs + yarn + spark + jupyter + history server)
- `compose.kafka.yml` -> kafka + kafka ui (redpanda console)
- `compose.seaweedfs.yml` -> seaweedfs (s3)
- `compose.nifi.yml` -> apache nifi (depende de seaweedfs e namenode)
- `compose.superset.yml` -> superset + postgres + redis
- `compose.airflow.yml` -> airflow + postgres (orquestración local; integra co clúster base)


---

## estrutura do repositorio

```
.
+-- compose.base.yml
+-- compose.airflow.yml
+-- compose.hadoop.yml
+-- compose.kafka.yml
+-- compose.seaweedfs.yml
+-- compose.nifi.yml
+-- compose.superset.yml
¦
+-- conf/                 # configuración xml de hadoop (core/hdfs/yarn/mapred)
+-- spark-conf/           # configuración específica de spark (spark-defaults.conf)
¦
+-- airflow/
¦   +-- dags/             # dags de airflow (bind mount)
¦   +-- config/           # configuración local de airflow (bind mount)
¦   +-- plugins/          # plugins personalizados de airflow (bind mount)
¦   +-- requirements.txt  # providers/paquetes Python adicionais para a imaxe de Airflow
¦   +-- Dockerfile        # build da imaxe personalizada de Airflow
¦
+-- jupyter/              # dockerfile + dependencias do contedor jupyterlab
+-- kafka/                # recursos e configuración asociados a kafka (se aplica)
¦
+-- jars/                 # jars auxiliares para Spark (volume opcional)
+-- scripts/              # scripts .ps1/.sh para arranque, parada e utilidades
¦   +-- up-base.ps1
¦   +-- init-airflow.ps1
¦   +-- up-airflow.ps1
¦   +-- up-airflow-seaweedfs.ps1
¦   +-- up-kafka.ps1
¦   +-- up-seaweedfs.ps1
¦   +-- up-nifi.ps1
¦   +-- up-all.ps1
¦   +-- down-airflow.ps1
¦   +-- down.ps1
¦   +-- down-v.ps1
¦   +-- down-all.ps1
¦   +-- logs-airflow.ps1
¦   +-- logs-ui.ps1
¦   +-- logs-kafka.ps1
¦   +-- logs-nifi.ps1
¦   +-- logs-notebook.ps1
¦   +-- ps.ps1
¦   +-- prep-exame.ps1
¦   +-- reset-checkpoins.ps1
¦   +-- reset-checkpoints.sh
¦   +-- reset-kafka-topics.ps1
¦   +-- reset-kafka.topics.sh
¦
+-- README.md
```

---

## estrutura de traballo recomendada (alumnado)

Este clúster está pensado para usarse xunto cun repositorio separado de notebooks de Spark.
Para evitar repositorios Git aniñados e facilitar o traballo, **ambos repositorios deben clonarse ao mesmo nivel**, dentro dun cartafol de traballo común.

A estrutura recomendada é a seguinte:
```bash
big-data-lab/ -> cartafol de traballo (non é repositorio git)
+-- big-data-cluster/ -> este repositorio
+-- spark-notebooks/ -> repositorio de notebooks de Spark
```


Importante: **o cartafol dos notebooks debe chamarse exactamente `spark-notebooks`**, xa que o contedor de Jupyter monta ese directorio como volume.

### clonado dos repositorios

```bash
mkdir big-data-lab
cd big-data-lab

git clone https://github.com/adbgonzalez/big-data-cluster big-data-cluster
git clone https://github.com/adbgonzalez/notebooks-spark-26-27 spark-notebooks

```
Unha vez clonados os dous repositorios, o clúster debe arrancarse desde o directorio **big-data-cluster/scripts**, tal e como se describe no apartado seguinte.

---

## inicio rápido (windows)

> en windows, a forma recomendada é usar os scripts `.ps1`.

### 1) arrancar o clúster base

```powershell
.\up-base.ps1
```

Isto levanta:
- namenode + datanode (hdfs)
- resourcemanager + nodemanager (yarn)
- spark history server
- jupyterlab (pyspark)

Para ver contedores activos:

```powershell
.\ps.ps1
```

Para consultar logs principais:

```powershell
.\logs-ui.ps1
```

---

### 2) activar módulos opcionais

#### kafka + kafka ui
```powershell
.\up-kafka.ps1
.\logs-kafka.ps1
```

#### seaweedfs (s3)
```powershell
.\up-seaweedfs.ps1
```

#### nifi (depende de seaweedfs + namenode)
```powershell
.\up-nifi.ps1
.\logs-nifi.ps1
```

#### superset
```powershell
docker compose -f compose.base.yml -f compose.superset.yml up -d
```

#### airflow
Antes do primeiro arranque de Airflow ou cando se modifique `airflow/requirements.txt`, hai que construír a imaxe personalizada:

```powershell
docker build -t adbgonzalez/airflow:3.1.8 .\airflow
```

Despois:

```powershell
.\init-airflow.ps1   # só a primeira vez / tras reset da BD de airflow
.\up-airflow.ps1     # levanta tamén o clúster base
.\logs-airflow.ps1
```

Se ademais queres levantar dependencias frecuentes para os DAGs:

```powershell
docker compose -f ..\compose.base.yml -f ..\compose.seaweedfs.yml -f ..\compose.airflow.yml up -d
.\up-kafka.ps1   # se tamén precisas kafka
```

`init-airflow.ps1` executa as migracións da base de datos de Airflow.  
`up-airflow.ps1` levanta o clúster base (`namenode`, `datanode`, `yarn`, `history`, `notebook`) xunto con `airflow-db`, `airflow-api-server`, `airflow-scheduler` e `airflow-dag-processor`.
O comando anterior de Docker Compose engade tamén `seaweedfs`, e `up-kafka.ps1` levanta ademais `kafka` e `redpanda-console`.

O stack de Airflow usa un `jwt_secret` compartido entre servizos para que a Execution API interna funcione correctamente en Airflow 3.

A imaxe personalizada de Airflow toma como base `apache/airflow:3.1.8` e instala os providers definidos en `airflow/requirements.txt`.

---

### 3) levantar todo (base + módulos)
```powershell
.\up-all.ps1
```

---

## interfaces web 

### clúster base
| servizo | url | descrición |
|--------|-----|------------|
| jupyterlab | http://localhost:8888 | notebooks con pyspark |
| hdfs namenode | http://localhost:9870 | navegador de hdfs |
| yarn resourcemanager | http://localhost:8088 | seguimento de aplicacións |
| spark history server | http://localhost:18080 | histórico de aplicacións spark |

### kafka
| servizo | url | descrición |
|--------|-----|------------|
| kafka broker | localhost:9092 | acceso desde host |
| kafka ui | http://localhost:8089 | redpanda console |

### seaweedfs
| servizo | url | descrición |
|--------|-----|------------|
| consola web | http://localhost:9001 | panel de administración |
| api s3 | http://localhost:9002 | endpoint s3 (porto 8333 interno) |

As credenciais S3 configúranse con `S3_ACCESS_KEY` e `S3_SECRET_KEY`. Os valores por defecto están definidos en `compose.seaweedfs.yml`.

### nifi
| servizo | url | descrición |
|--------|-----|------------|
| nifi (https) | https://localhost:9091 | ui web |

credenciais por defecto:
- user: `admin`
- pass: `Admin.BDA123!`

(pódense cambiar con `NIFI_USER` e `NIFI_PASS`)

### superset
| servizo | url | descrición |
|--------|-----|------------|
| superset | http://localhost:8090 | bi e dashboards |

credenciais por defecto:
- user: `admin`
- pass: `admin`

### airflow
| servizo | url | descrición |
|--------|-----|------------|
| airflow ui/api | http://localhost:8091 | orquestración local e execución de DAGs |

acceso:
- sen login (configurado para contorno local de prácticas)

nota:
- inclúe un DAG mínimo de proba en `airflow/dags/hello_airflow.py`
- pódense engadir providers de Airflow modificando `airflow/requirements.txt` e reconstruíndo a imaxe `adbgonzalez/airflow:3.1.8`

---

## exemplo rápido: spark sobre yarn desde jupyterlab

Abre http://localhost:8888 e crea un notebook python.

```python
import findspark
findspark.init("/opt/spark")

from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("test-yarn")
    .master("yarn")
    .config("spark.eventLog.enabled", "true")
    .config("spark.eventLog.dir", "hdfs://namenode:9000/spark-logs")
    .getOrCreate()
)

spark.range(1, 1000000).selectExpr("sum(id)").show()
```

O resultado debería aparecer tamén no history server (http://localhost:18080).

---

## xestión do clúster

### parar servizos (sen borrar volumes)
```powershell
.\down.ps1
```

### parar e borrar volumes (elimina datos persistentes)
```powershell
.\down-v.ps1
```

### parar todo (incluíndo módulos)
```powershell
.\down-all.ps1
```

---

## utilidades

### reset de checkpoints (streaming)
```powershell
.\reset-checkpoins.ps1
```

ou en linux:
```bash
./reset-checkpoints.sh
```

### reset de tópicos kafka
```powershell
.\reset-kafka-topics.ps1
```

ou en linux:
```bash
./reset-kafka.topics.sh
```


---

## créditos

mantido por **adrián blanco (cifp a carballeira)**
