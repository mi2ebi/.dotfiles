use std::{collections::HashSet, fmt::Write as _, fs, process::exit};

fn to_slug(c: char) -> String {
    if c.is_ascii_alphanumeric() {
        return c.to_string();
    }
    match c {
        '~' => "tild",
        '`' => "grav",
        '!' => "bang",
        '@' => "aaat",
        '#' => "hash",
        '$' => "dolr",
        '%' => "pcnt",
        '^' => "cart",
        '&' => "amps",
        '*' => "star",
        '(' => "lpar",
        ')' => "rpar",
        '_' => "undr",
        '-' => "hyph",
        '+' => "plus",
        '=' => "eqal",
        '[' => "lbrk",
        '{' => "lbrc",
        ']' => "rbrk",
        '}' => "rbrc",
        '\\' => "bsla",
        '|' => "pipe",
        ';' => "semi",
        ':' => "coln",
        '\'' => "apos",
        '"' => "quot",
        '<' => "less",
        '>' => "grea",
        ',' => "coma",
        '.' => "peri",
        '/' => "slas",
        '?' => "ques",
        other => panic!("no slug defined for {other:?}"),
    }
    .to_string()
}

fn to_key(c: char) -> String {
    if c.is_ascii_lowercase() || c.is_ascii_digit() {
        return c.to_string();
    }
    if c.is_ascii_uppercase() {
        return format!("S-{}", c.to_ascii_lowercase());
    }
    match c {
        '`' => "`",
        '~' => "S-`",
        '-' => "-",
        '_' => "S--",
        '=' => "=",
        '+' => "S-=",
        '[' => "[",
        '{' => "S-[",
        ']' => "]",
        '}' => "S-]",
        '\\' => "\\",
        '|' => "S-\\",
        ';' => ";",
        ':' => "S-;",
        '\'' => "'",
        '"' => "S-'",
        ',' => ",",
        '<' => "S-,",
        '.' => ".",
        '>' => "S-.",
        '/' => "/",
        '?' => "S-/",
        '!' => "S-1",
        '@' => "S-2",
        '#' => "S-3",
        '$' => "S-4",
        '%' => "S-5",
        '^' => "S-6",
        '&' => "S-7",
        '*' => "S-8",
        '(' => "S-9",
        ')' => "S-0",
        other => panic!("no key mapping for {other:?} (us qwerty only)"),
    }
    .to_string()
}

#[allow(clippy::many_single_char_names, reason = "annoying")]
fn main() {
    let contents = fs::read_to_string("seqs.txt").expect("can't open seqs.txt");
    let mut warnings = vec![];
    let mut seen = HashSet::new();
    let mut seqs_lines = Vec::new();
    let mut entries = contents
        .lines()
        .filter_map(|line| {
            let line = line.trim().to_string();
            if line.is_empty() {
                return None;
            }
            let fields: Vec<&str> = line.split_whitespace().collect();
            if fields.len() != 2 && fields.len() != 3 {
                warnings.push(format!("expected 2 or 3 fields, got {}: {line}", fields.len()));
                return None;
            }
            let s = fields[0];
            let x = fields[1];
            if !s.chars().all(|ch| ch.is_ascii_graphic()) {
                warnings.push(format!("seq {s} has non-graphical-ascii chars"));
            }
            if s.len() > 4 {
                warnings.push(format!("seq {s} is {} characters, max is 4", s.len()));
            }
            let Ok(n) = u32::from_str_radix(x, 16) else {
                warnings.push(format!("{x} isn't valid hex"));
                return None;
            };
            let Some(xchar) = char::from_u32(n) else {
                warnings.push(format!("{n:x} isn't a valid unicode codepoint"));
                return None;
            };
            let x = format!("{n:x}");
            let mut line = format!("{s} {x}");
            if fields.len() == 3 {
                let c = fields[2];
                line = format!("{line} {c}");
                let mut cchars = c.chars();
                match (cchars.next(), cchars.next()) {
                    (Some(given), None) if given == xchar => {}
                    (Some(given), None) => warnings.push(format!(
                        "hex {x} (={xchar:?}) doesn't match char {given:?} (={:x})",
                        given as u32
                    )),
                    _ => warnings.push(format!("char field {c:?} isn't a single character")),
                }
            }
            if !seen.insert(s.to_string()) {
                warnings.push(format!("duplicate seq {s}"));
            }
            seqs_lines.push((n, line));
            let name = format!("seq:{}", s.chars().map(to_slug).collect::<Vec<_>>().join("-"));
            let keys = s.chars().map(to_key).collect::<Vec<_>>().join(" ");
            Some((name, keys, xchar))
        })
        .collect::<Vec<_>>();
    entries.sort_by_key(|(_, _, c)| *c);
    if !warnings.is_empty() {
        for w in warnings {
            println!("\x1b[93m{w}\x1b[m");
        }
        exit(1);
    }
    seqs_lines.sort_by_key(|(n, _)| *n);
    let sorted_seqs =
        seqs_lines.into_iter().map(|(_, line)| line).collect::<Vec<_>>().join("\n") + "\n";
    fs::write("seqs.txt", sorted_seqs).unwrap();
    let mut out = "(defvirtualkeys\n".to_string();
    for (name, _, c) in &entries {
        writeln!(out, "  {name} (unicode {c})").unwrap();
    }
    out += ")\n(defseq\n";
    for (name, keys, _) in &entries {
        writeln!(out, "  {name} ({keys} nop0)").unwrap();
    }
    out += ")\n";
    fs::write("seqs.kbd", out).unwrap();
    println!("done");
}
