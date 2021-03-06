module Lang4Test where

import Data.Map(Map, lookup, insert, empty, fromList)  -- for State

import Test.Tasty (testGroup)
import Test.Tasty.HUnit (assertEqual, assertBool, testCase)
import Test.Tasty.QuickCheck

import Lang4(Ast(AstInt,Plus,Separator,Let,Id), eval)
import Lang4Parser(unsafeParser, parser)

-- note: probly could be better
instance Arbitrary Ast where
    arbitrary = sized arbitrarySizedAst

arbitrarySizedAst ::  Int -> Gen Ast
arbitrarySizedAst m | m < 1     = do i <- arbitrary
                                     return $ AstInt i
arbitrarySizedAst m | otherwise = do l <- arbitrarySizedAst (m `div` 2)
                                     r <- arbitrarySizedAst (m `div` 2)
                                     str <- elements ["x","y","z"]
                                     node <- elements [Plus l r, Separator l r, Id str, Let str l r ]
                                     return node


unitTests =
  testGroup
    "Lang4Test"
    [instructorTests,
     -- TODO: your tests here
     parseShowTests]

instructorTests = testGroup
      "instructorTests"
      [
      testCase "example eval" $ assertEqual []  (Just 6) $ eval empty (Let "x" (AstInt 3) ((Id "x") `Plus` (Id "x")) ) ,

      testCase "example eval" $ assertEqual []  (Just 5) $ eval empty (Let "x" (AstInt 3)
                                                                          ((Let "x" (AstInt 1)
                                                                           ((Id "x") `Plus` (Id "x")))  `Plus` (Id "x")) ),
-- see https://piazza.com/class/jlpaiu7tfht5ro?cid=490
--       testCase "parse test: let x= 3+3 in x; (let y = x + 7 in x + y)+x" $ assertEqual []
--                                               (Just (Let "x" (Plus (AstInt 3) (AstInt 3)) (Separator (Id "x") (Plus (Let "y" (Plus (Id "x") (AstInt 7)) (Plus (Id "x") (Id "y"))) (Id "x"))),"")) $
--                                              parser "let x= 3+3 in x; (let y = x + 7 in x + y)+x",

      testCase "parse test: let x = 3 in x+x" $ assertEqual []
                                             (Just 6) $
                                             eval empty  (unsafeParser " let x = 3 in x+x"),

      testCase "parse test:  let x = 3 in (let x= 1 in x+x) + x" $ assertEqual []
                                             (Just 5) $
                                              eval empty  (unsafeParser " let x = 3 in (let x= 1 in x+x) + x"),

      testProperty "show should match parse" $ ((\ x -> Just (x , "") == (parser $ show x)) :: Ast -> Bool)]


-- TODO: add a generator, every show should be parsable, test the Eq laws, tests from prevous languages and week 5, many many more examples
-- TODO: you should always be able to parse show (when the var names aren't too bad)

parseShowTests = testGroup
      "parseShowTests"
      [
      testCase "test parsing show AstInt" $ assertEqual [] (Just ((AstInt 2), "")) $ (parser (show (AstInt 2))),

      testCase "test parsing show Plus" $ assertEqual [] (Just ((Plus (AstInt 2) (AstInt 3)),"")) $ (parser (show (Plus (AstInt 2) (AstInt 3)))),
      
      testCase "test parsing show Separator" $ assertEqual [] (Just ((Separator (AstInt 2) (AstInt 3)),"")) $ (parser (show (Separator (AstInt 2) (AstInt 3)))),

      testCase "test parsing show Id" $ assertEqual [] (Just ((Id "x"), "")) $ (parser (show (Id "x"))),

      testCase "test parsing show Let" $ assertEqual [] (Just ((Let "x" (Plus (AstInt 3) (AstInt 2)) (Plus (Id "x") (Id "x"))),"")) $ (parser (show ((Let "x" (Plus (AstInt 3) (AstInt 2)) (Plus (Id "x") (Id "x")))))),

      testCase "test eval parsing show Let" $ assertEqual [] (Just 10) $ eval empty (unsafeParser (show ((Let "x" (Plus (AstInt 3) (AstInt 2)) (Plus (Id "x") (Id "x"))))))
      ]
