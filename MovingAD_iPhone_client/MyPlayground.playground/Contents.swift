//: Playground - noun: a place where people can play

import UIKit

//1[34578][0-9]{9}
let str = "1880s0002222"
let pattern = "1[34578][0-9]{9}"

str.rangeOfString(pattern, options: .RegularExpressionSearch)