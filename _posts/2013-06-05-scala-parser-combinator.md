---
title:  "Scala's parser combinator"
date:   2013-06-05
tags: [Scala]
---

After playing around a little recently with Scala's parser combinator, I tried to implement a small calculator-like program using them to see how easily it could be done. The result is quite impressive, with about 100 lines of code we can get something working pretty fine.

# AST

I used this class as a base for my AST.

```scala
abstract class Expression {
  def evaluate: Option[Double]
}
```

the `Option` is used to return `None` when a variable is not found during the evaluation. I guess a case class with a bit more appropriate information in case of failure would be better in a real world example though.
The subclasses of `Expression` are implemented as follow:

```scala
case class Assignement (
  left: Variable,
  right: Expression
) extends Expression {
  override def evaluate: Option[Double] = {
    right evaluate match {
      case Some(result) => {
        Variables.set(left, result)
        Some(result)
      }
      case _ => None
    }
  }
}

case class Computation (
  operator: Operator,
  left: Expression,
  right: Expression
) extends Expression {
  override def evaluate: Option[Double] = {
    (left evaluate, right evaluate) match {
      case (Some(a), Some(b)) => Some(operator.execute(a, b))
      case _ => None
    }
  }
}

case class Number (
  n: Double
) extends Expression {
  def evaluate: Option[Double] = Some(n)
}

case class Variable (
  name: String
) extends Expression {
  def evaluate: Option[Double] = Variables.get(this)
}
```

The `Computation` class would probably need to be a bit more flexible, to at least allow unary operations. Splitting it in two subclasses would be enough for this example.
The `Variables` object used is simply

```scala
object Variables {
  private[this] var variables = Map[Variable, Double]()
  def set(v: Variable, n: Double) = variables += (v -> n)
  def get(v: Variable) = variables.get(v)
}
```

and the `Operator` class is a class to define basic arithmetic operations:

```scala
object Operator {
  def fromString(c: String) = c match {
    case "+" => Plus
    case "-" => Minus
    case "*" => Times
    case "/" => Divide
  }
}

abstract class Operator {
  def execute(a: Double, b: Double): Double
}

case object Plus extends Operator {
  override def execute(a: Double, b: Double) = a + b
}

case object Minus extends Operator {
  override def execute(a: Double, b: Double) = a - b
}

case object Times extends Operator {
  override def execute(a: Double, b: Double) = a * b
}

case object Divide extends Operator {
  override def execute(a: Double, b: Double) = a / b
}
```

here, I'm only handling cases where both numbers are `double`, so `1 + 1 = 2.0` and not simply 2.

# Parser

That's enough for the AST, let's take a look at the parser combinator part.

I extended the `JavaTokenParsers` here to have the `ident` and `floatingPointNumber` ready to use. The code looks like this

```scala
import scala.util.parsing.combinator.JavaTokenParsers

trait CalculatorParser extends JavaTokenParsers {
  private def makeComputation(
    exp: Expression,
    li: List[String~Expression]
  ): Expression = (exp /: li) {
    case (exp, c~e) => Computation(Operator.fromString(c), exp, e)
  }

  def expression: Parser[Expression] = assignment|exprComputation

  def exprComputation: Parser[Expression] = term ~ rep(("+"|"-") ~ term) ^^ {
    case e~xs => makeComputation(e, xs)
  }

  def assignment: Parser[Assignement] = (variable<~"=")~expression ^^ {
    case v~e => Assignement(v, e)
  }

  def term: Parser[Expression] = primary ~ rep(("*"|"/") ~ primary) ^^ {
    case p~xs => makeComputation(p, xs)
  }

  def primary: Parser[Expression] = number | variable | "("~>expression<~")"

  def number: Parser[Number] = floatingPointNumber ^^ (v => Number(v.toDouble))

  def variable: Parser[Variable] = ident ^^ (s => Variable(s))
}
```

The `makeComputation` methods uses `foldLeft` to build a `Computation` from an expression and a list of expressions with operators. I made it a different method as it is used by `exprComputation` and `term`, but it is not part of the parser. The rest of the parser is pretty straight forward. An expression (top level in this syntax) can be an assignement or an `exprComputation`, which is a term followed by zero or more additions or substractions of other terms.
Everything here is pretty much the same as what the EBNF for the language would look like, with eventually an anonymous function to get an AST member.

That's pretty much it, the code to run the parser simply looks like

```scala
object Main extends CalculatorParser {
  def main(args: Array[String]) {
    for(ln <- io.Source.stdin.getLines) {
      parseAll(expression, ln) match {
        case Success(result, _) => result evaluate match {
          case Some(v) => println(v)
          case None => scala.sys.error("missing variable")
        }
        case failure: NoSuccess => scala.sys.error(failure.msg)
      }
    }
  }
}
```

which should be easy enough to understand.

# Thoughts

This was a little experiment to try to see how easy-to-use was Scala's combinator parser compared to tools like flex and bison.
I haven't tried any benchmark to compare performance, but from a usability point of view, I think that it could hardly be simpler.
Scala's parser combinator doesn't seem to support left recursion though, but this should be easy to avoid in almost all cases.
Anyway, this is a really nice tool which should be really convenient to easily deal with DSL.
