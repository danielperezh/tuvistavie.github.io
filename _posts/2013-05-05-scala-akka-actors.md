---
title:  "Getting started with Scala's akka actors"
date:   2013-05-21
tags: [Scala, Akka]
---

I've been looking for a sample code to get started with Akka actors, but after looking around a little, the only non trivial example I found was the [akka 1.3 Getting started page](http://doc.akka.io/docs/akka/1.3/intro/getting-started-first-scala.html).

I tried to adapt this to the latest release of akka (2.4 while I'm writing this), so here are the main changes. By the way, I'm using Scala 2.10.1 version.

## Disclaimer
I'm only starting with akka library, and I'm sure there are some more elegant and efficient ways to do that. That's pretty much try to at least get things working.

## Imports

The imports themselves have more or less completely changed, so it's better not to start trying to go with the original version. All we'll be needing is

```scala
import akka.actor._
import akka.routing._
```

and if you don't want to import stuff you won't be using, you can use

```scala
import akka.actor.{Actor, PoisonPill, Props, ActorSystem}
import akka.routing.{RoundRobinRouter, Broadcast}
```

# The code

## `Worker` class

The main change here is that `reply` is no longer a method of the `Actor` trait, and therefore to reply we have to use the implicit `sender` object.

```scala
  class Worker extends Actor {
    def receive = {
      case Work(start, nbOfElements) =>
      sender ! Result(calculatePiFor(start, start + nbOfElements))
    }

    def calculatePiFor(start: Int, stop: Int): Double = {
      (start until stop) map { i =>
        4.0 * (1 - (i % 2) * 2) / (2 * i + 1)
      } sum
    }
  }
```

## The router

The router has been simplified (at least for basic usage), and there is no need to create the actors, it can be automatically handled. The code for the router becomes simply

```scala
val router = context.actorOf(
  Props[Worker].withRouter(RoundRobinRouter(nbOfWorkers))
)
```

where `nbOfWorkers` is the number of `Worker` actors which will be supervised by the router. I chose `RoundRobinRouter` here because it was what seemed to be the closest to the `CyclicIterator` in the original code.

## Message handler

The message handling part in the `Master` is pretty much the same, but the `stop` method is not part of the `Actor` trait anymore. In 2.x versions, the trait `ActorContext` seems to be responsible for that job, so to stop the actor, the code becomes

```scala
if(nbOfResults == nbOfMessages) {
  context.stop()
}
```

however, as we don't really need any thing more once the master has done his job, I chose to stop the system the master belongs to itself by using

```scala
if(nbOfResults == nbOfMessages) {
  context.system.shutdown()
}
```

though I'm not really sure if that's the right way to do it.

## Full code

I finally ended up with a code like this:

```scala
import akka.actor.{Actor, PoisonPill, Props, ActorSystem}
import akka.routing.{RoundRobinRouter, Broadcast}

object Main {

  def main(args: Array[String]): Unit = {
    calculate(nbOfWorkers = 4, nbOfElements = 10000, nbOfMessages = 10000)
  }

  sealed trait PiMessage

  case object Calculate extends PiMessage

  case class Work(start: Int, nbOfElements: Int) extends PiMessage

  case class Result(value: Double) extends PiMessage


  class Worker extends Actor {
    def receive = {
      case Work(start, nbOfElements) =>
      sender ! Result(calculatePiFor(start, start + nbOfElements))
    }

    def calculatePiFor(start: Int, stop: Int): Double = {
      (start until stop) map { i =>
        4.0 * (1 - (i % 2) * 2) / (2 * i + 1)
      } sum
    }
  }

  class Master (
    nbOfWorkers: Int,
    nbOfMessages: Int,
    nbOfElements: Int
  ) extends Actor {

    var pi: Double = 0.0
    var nbOfResults: Int = 0
    var start: Long = 0

    val router = context.actorOf(
      Props[Worker].withRouter(RoundRobinRouter(nbOfWorkers))
    )

    def receive = {
      case Calculate => {
        for (i <- 0 until nbOfMessages) {
          router ! Work(i * nbOfElements, nbOfElements)
        }
      }

      case Result(value) => {
        pi += value
        nbOfResults += 1
        if(nbOfResults == nbOfMessages) {
          context.system.shutdown()
        }
      }
    }

    override def preStart() {
      start = System.currentTimeMillis
    }

    override def postStop() {
      println(
        "\n\tPi estimate: \t\t%s\n\tCalculation time: \t%s millis"
        .format(pi, System.currentTimeMillis - start))
    }
  }


  def calculate(nbOfWorkers: Int, nbOfElements: Int, nbOfMessages: Int) {
    val system = ActorSystem("PiCalculator")

    val master = system.actorOf(Props(
      new Master(nbOfWorkers, nbOfMessages, nbOfElements)))

    master ! Calculate
  }
}
```

I used `sbt` to download the akka dependencies for me with this `build.sbt`

```scala
name := "Pi"

version := "1.0"

scalaVersion := "2.10.3"

resolvers += "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/"

libraryDependencies += "com.typesafe.akka" %% "akka-actor" % "2.1.4"

scalacOptions ++= Seq("-feature", "-language:postfixOps")
```

and I compiled and ran the program.

```bash
-> % sbt
[info] Set current project to Pi (in build file:/home/daniel/tmp/tutorial/)
run
[info] Updating {file:/home/daniel/tmp/abc/}abc...
[info] Resolving org.fusesource.jansi#jansi;1.4 ...
[info] Done updating.
[info] Compiling 1 Scala source to /home/daniel/tmp/abc/target/scala-2.10/classes...
[info] Running Main

	Pi estimate: 		3.1415926435897887
	Calculation time: 	1002 millis
[success] Total time: 6 s, completed Sep 29, 2014 9:28:22 PM
```

It's not the best approximation of π I've seen, but well at least everything seems to be working fine.
