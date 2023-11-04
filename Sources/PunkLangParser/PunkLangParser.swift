//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation
import PrettyTree

fileprivate let sourceCode1: String = """
\\h1{Hello World}
\\layout{
    \\note{
        \\h2{Hello World}
        Cake marzipan muffin halvah cotton candy shortbread wafer.
    }
    \\note{
        \\h2{Hello World}
        Cake marzipan muffin halvah cotton candy shortbread wafer. Sweet roll halvah muffin sweet roll brownie jujubes cheesecake. Topping icing cheesecake soufflé bear claw tiramisu pie jelly beans…
        \\equations{
            f(x)=y = e^x
        } {
            f(x)=y = e^x
        } {
            \\frac{dy}{dx} &= f(x)
        }
    }
    \\note {
        \\h3{Symmetric Equation of a Line}
        Given
        \\equations{
            t &= \\frac{x - x_1}{x_2-x_1} = \\frac{x - x_1}{\\Delta_x}
        } {
            t &= \\frac{y - y_1}{y_2-y_1} = \\frac{y - y_1}{\\Delta_y}
        } {
            t &= \\frac{z - z_1}{z_2-z_1} = \\frac{z - z_1}{\\Delta_z}
        }
        Therefore
        \\equations{
            \\frac{x - x_1}{Delta_x} &= \\frac{y - y_1}{\\Delta_y} = \\frac{z - z_1}{\\Delta_z}
        } {
            \\frac{x - x_1}{x_2-x_1} &= \\frac{y - y_1}{y_2-y_1} =  \\frac{z - z_1}{z_2-z_1}
        }
        \\hr
        \\h4{Rationale}
        We rewrite \\{r = r_0 + a = r_0 + t v} in terms of \\{t}.
        That is
        \\equations{
            x &= x_1 + t(x_2-x_1) = x_1 + t\\;Delta_x
        } {
            t\\;Delta_x  &= x - x_1 = t(x_2-x_1)
        } {
            t &= \\frac{x - x_1}{x_2-x_1} = \\frac{x - x_1}{Delta_x}
        } {
            y &= y_1 + t(y_2-y_1) = y_1 + t\\;\\Delta_y
        } {
            t\\;\\Delta_y  &= y - y_1 = t(y_2-y_1)
        } {
            t &= \\frac{y - y_1}{y_2-y_1} = \\frac{y - y_1}{\\Delta_y}
        } {
            z &= z_1 + t(z_2-z_1) = z_1 + t\\;\\Delta_z
        } {
            t\\;\\Delta_z &= z - z_1 = t(z_2-z_1)
        } {
            t &= \\frac{z - z_1}{z_2-z_1} = \\frac{z - z_1}{\\Delta_z}
        }
    }
}
"""
fileprivate let sourceCode2: String = """
\\h1{{\\em{Hello} \\b{World}}}
"""
fileprivate let sourceCode3: String = """
\\h1{{Hello World}}
"""


fileprivate func dev() {
    let tokens = Parser.TokenValue.tokenize(source: sourceCode2)
    let blockTree = Parser.BlockTree.build(tokens: tokens)
    let ast = blockTree.asSyntaxTree.normalize()
    ast.prettyTree.print()
}

public struct PunkLangParser {
    public static func main() {
        print("Running PunkLangParser")
        dev()
    }
}
