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

fn group_shift_keys(keys: &str) -> Option<String> {
    let parts: Vec<&str> = keys.split(' ').collect();
    let mut out = Vec::new();
    let mut modified = false;
    let mut i = 0;
    while i < parts.len() {
        if parts[i].starts_with("S-") {
            let mut run = vec![&parts[i][2 ..]];
            let mut j = i + 1;
            while j < parts.len() && parts[j].starts_with("S-") {
                run.push(&parts[j][2 ..]);
                j += 1;
            }
            if run.len() >= 2 {
                out.push(format!("S-({})", run.join(" ")));
                modified = true;
                i = j;
                continue;
            }
        }
        out.push(parts[i].to_string());
        i += 1;
    }
    modified.then(|| out.join(" "))
}

#[allow(clippy::many_single_char_names, reason = "annoying")]
fn main() {
    let contents = fs::read_to_string("seqs.txt").expect("can't open seqs.txt");
    let mut warnings = vec![];
    let mut seen = HashSet::new();
    let mut entries = contents
        .lines()
        .enumerate()
        .filter_map(|(i, line)| {
            let i = i + 1;
            if line.trim().is_empty() {
                return None;
            }
            let fields: Vec<&str> = line.split(' ').collect();
            if fields.len() != 2 && fields.len() != 3 {
                warnings.push(format!("line {i}: expected 2 or 3 fields, got {}", fields.len()));
                return None;
            }
            let s = fields[0];
            let x = fields[1];
            if !s.chars().all(|ch| ch.is_ascii_graphic()) {
                warnings.push(format!("line {i}: seq {s} has non-graphical-ascii chars"));
            }
            if s.len() > 4 {
                warnings.push(format!("line {i}: seq {s} is {} characters, max is 4", s.len()));
            }
            let Ok(n) = u32::from_str_radix(x, 16) else {
                warnings.push(format!("line {i}: {x} isn't valid hex"));
                return None;
            };
            let Some(xchar) = char::from_u32(n) else {
                warnings.push(format!("line {i}: {n:x} isn't a valid unicode codepoint"));
                return None;
            };
            if fields.len() == 3 {
                let c = fields[2];
                let mut cchars = c.chars();
                match (cchars.next(), cchars.next()) {
                    (Some(given), None) if given == xchar => {}
                    (Some(given), None) => warnings.push(format!(
                        "line {i}: hex {x} (={xchar:?}) doesn't match char {given:?} (={:x})",
                        given as u32
                    )),
                    _ => warnings
                        .push(format!("line {i}: char field {c:?} isn't a single character")),
                }
            }
            if !seen.insert(s.to_string()) {
                warnings.push(format!("line {i}: duplicate seq {s}"));
            }
            let name = format!("seq:{}", s.chars().map(to_slug).collect::<Vec<_>>().join("-"));
            let keys = s.chars().map(to_key).collect::<Vec<_>>().join(" ");
            Some((name, keys, xchar))
        })
        .collect::<Vec<_>>();
    let mut extra = Vec::new();
    for (name, keys, c) in &entries {
        if let Some(grouped) = group_shift_keys(keys) {
            extra.push((format!("{name}-grp"), grouped, *c));
        }
    }
    entries.extend(extra);
    if !warnings.is_empty() {
        for w in warnings {
            println!("\x1b[93m{w}\x1b[m");
        }
        exit(1);
    }
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
