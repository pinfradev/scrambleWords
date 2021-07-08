//
//  ContentView.swift
//  WordScramble
//
//  Created by Fray Pineda on 27/6/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
  
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                List(usedWords,
                     id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                .autocapitalization(.none)
                .navigationBarTitle(rootWord)
                .onAppear(perform: startGame)
                .alert(isPresented: $showingError, content: {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                })
                
                Text("Your score is: \(score)")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Start game", action: startGame)
                }
            }
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let minimumNumberOfLetters = 3
        
        guard word.count > minimumNumberOfLetters,
              word != rootWord else {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "WordUsedAlready", error: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "wordNotRecognized", error: "You can't just make them up, you know! ")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "word not possible", error: "that isn't a real word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        calculateScore()
        newWord = ""
    }
    
    func calculateScore() {
        let letters = usedWords[0].count
        score += letters
    }
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkwork"
                usedWords.removeAll()
                score = 0
                newWord = ""
                return
            }
        }
        
        fatalError("Could not load txt from bundle")
    }
    
    func wordError(title: String, error: String) {
        errorTitle = title
        errorMessage = error
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
