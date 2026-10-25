+++
title = "Ein einfacher C++ Tokenizer"
description = "Sehr viele Daten müssen erstmal aus einer Datei eingelesen werden. Dabei kann ein Tokenizer gute Dienste leisten um strukturierte Daten in die entsprechenden Stücke zu unterteilen."
date = 2009-03-25T20:00:00

aliases = [
    "/2009/03/ein-einfacher-c-tokenizer",
]
+++

```cpp
#ifndef TOKENIZER_H_
#define TOKENIZER_H_

#include <string>

using namespace std;

enum DelimType
{
  WHITESPACE = 0, ORDINARY = 1
};

class Tokenizer
{
public:
  Tokenizer(const string text);
  virtual ~Tokenizer();

  bool has_next();
  string next();

  void add_delims(int begin, int end, DelimType type);

private:
  void find_token();

private:
  unsigned int _pos;
  string _text;
  string _token;
  bool _token_available;
  DelimType _delims[256];
};

#endif
```

```cpp
#include <iostream>

#include "Tokenizer.h"

Tokenizer::Tokenizer(const string text) :
  _pos(0), _text(text), _token_available(false)
{
  _token.clear();
  add_delims(0x0, 0xFF, WHITESPACE);
  add_delims(0x30, 0x39, ORDINARY);
  add_delims(0x41, 0x5A, ORDINARY);
  add_delims(0x61, 0x7A, ORDINARY);
}

Tokenizer::~Tokenizer()
{
}

bool Tokenizer::has_next()
{
  find_token();

  if (_token_available)
  {
    return true;
  }

  return false;
}

string Tokenizer::next()
{
  find_token();

  if (_token_available)
  {
    _token_available = false;
    return _token;
  }

  throw "No next token!";
}

void Tokenizer::add_delims(int begin, int end, DelimType type)
{
  if (begin < 0)
  {
    begin = 0;
  }

  if (end > 255)
  {
    end = 255;
  }

  for (int i = begin; i <= end; ++i)
  {
    _delims[i] = type;
  }
}

void Tokenizer::find_token()
{
  if (_pos >= _text.length() || _token_available)
  {
    return;
  }

  _token.clear();
  _token_available = false;

  while (_pos < _text.length())
  {
    char chr = _text.at(_pos);
    DelimType type = _delims[(int) chr];
    _pos++;

    if (type == ORDINARY)
    {
      _token.append(1, chr);
      _token_available = true;
    }
    else if (_token_available && type == WHITESPACE)
    {
      break;
    }
  }
}
```
