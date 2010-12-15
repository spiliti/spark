EMPTY =
SPACE = $(EMPTY) $(EMPTY)

# Build up classpath by concatenating some strings
JARS = third_party/mesos.jar
JARS += third_party/asm-3.2/lib/all/asm-all-3.2.jar
JARS += third_party/colt.jar
JARS += third_party/guava-r07/guava-r07.jar
JARS += third_party/hadoop-0.20.0/hadoop-0.20.0-core.jar
JARS += third_party/hadoop-0.20.0/lib/commons-logging-1.0.4.jar
JARS += third_party/scalatest-1.2/scalatest-1.2.jar
JARS += third_party/scalacheck_2.8.0-1.7.jar
JARS += third_party/jetty-7.1.6.v20100715/jetty-server-7.1.6.v20100715.jar
JARS += third_party/jetty-7.1.6.v20100715/servlet-api-2.5.jar
JARS += third_party/apache-log4j-1.2.16/log4j-1.2.16.jar
JARS += third_party/slf4j-1.6.1/slf4j-api-1.6.1.jar
JARS += third_party/slf4j-1.6.1/slf4j-log4j12-1.6.1.jar
JARS += third_party/compress-lzf-0.6.0/compress-lzf-0.6.0.jar

CLASSPATH = $(subst $(SPACE),:,$(JARS))

SCALA_SOURCES =  src/examples/*.scala src/scala/spark/*.scala src/scala/spark/repl/*.scala
SCALA_SOURCES += src/test/spark/*.scala src/test/spark/repl/*.scala


ifeq ($(USE_FSC),1)
  COMPILER_NAME = fsc
else
  COMPILER_NAME = scalac
endif

ifeq ($(SCALA_HOME),)
  COMPILER = $(COMPILER_NAME)
else
  COMPILER = $(SCALA_HOME)/bin/$(COMPILER_NAME)
endif

CONF_FILES = conf/spark-env.sh conf/log4j.properties conf/java-opts

all: scala conf-files

build/classes:
	mkdir -p build/classes

scala: build/classes
	$(COMPILER) -d build/classes -classpath build/classes:$(CLASSPATH) $(SCALA_SOURCES)

jar: build/spark.jar build/spark-dep.jar

dep-jar: build/spark-dep.jar

build/spark.jar: scala
	jar cf build/spark.jar -C build/classes spark

build/spark-dep.jar:
	mkdir -p build/dep
	cd build/dep &&	for i in $(JARS); do jar xf ../../$$i; done
	jar cf build/spark-dep.jar -C build/dep .

conf-files: $(CONF_FILES)

$(CONF_FILES): %: | %.template
	cp $@.template $@

test: all
	./alltests

default: all

clean:
	rm -rf build

.phony: default all clean scala jar dep-jar conf-files
