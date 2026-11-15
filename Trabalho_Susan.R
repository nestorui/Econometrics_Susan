# ============================================================
# Trabalho de Econometria I - Setor 09 (primeiras 200 obs)
# ============================================================

# ---- 0. Pacotes ----
# install.packages(c("readxl", "lmtest", "sandwich", "car", "tseries", "ggplot2"))
library(readxl)
library(lmtest)
library(sandwich)
library(car)
library(ggplot2)

# ---- 1. Leitura dos dados ----
dados <- read_excel("Trab_setores_dados.xls", sheet = "Sheet1")

# Renomear primeira coluna (data) e converter
names(dados)[1] <- "data"
dados$data <- as.Date(dados$data)

# Selecionar setor09 + variáveis explicativas
# Colunas: data, setor09 (col D), cambio (col Y), ibcbr (col Z),
# dummies fev..dez (col AA..AL)
dados <- dados[!is.na(dados$data), ]   # remove linhas vazias

# Primeiras 200 observações
d <- dados[1:200, c("data", "setor09", "cambio", "ibcbr",
                    "fev","mar","abr","mai","jun","jul","ago","set","out","nov","dez")]
d <- as.data.frame(d)
d$setor09 <- as.numeric(d$setor09)
d$cambio  <- as.numeric(d$cambio)
d$ibcbr   <- as.numeric(d$ibcbr)
for (v in c("fev","mar","abr","mai","jun","jul","ago","set","out","nov","dez"))
  d[[v]] <- as.numeric(d[[v]])

cat("Amostra:", nrow(d), "obs | de", as.character(min(d$data)),
    "a", as.character(max(d$data)), "\n")

# ============================================================
# QUESTÃO 1 - Regressão simples + gráficos
# ============================================================
m1 <- lm(setor09 ~ cambio + ibcbr, data = d)
summary(m1)

# Gráficos das três variáveis ao longo do tempo
par(mfrow = c(3,1), mar = c(2,4,2,1))
plot(d$data, d$setor09, type="l", col="steelblue", xlab="", ylab="setor09 (%)",
     main="Variação % mensal - Setor 09")
abline(h=0, lty=2, col="gray")
plot(d$data, d$cambio, type="l", col="darkred", xlab="", ylab="cambio (%)",
     main="Variação % mensal - Câmbio")
abline(h=0, lty=2, col="gray")
plot(d$data, d$ibcbr, type="l", col="darkgreen", xlab="Data", ylab="ibcbr (%)",
     main="Variação % mensal - IBC-Br")
abline(h=0, lty=2, col="gray")
par(mfrow = c(1,1))

# ============================================================
# QUESTÃO 2 - Ljung-Box e Breusch-Pagan no modelo 1
# ============================================================
# Ljung-Box (autocorrelação dos resíduos)
lb1 <- Box.test(resid(m1), lag = 12, type = "Ljung-Box", fitdf = 2)
print(lb1)

# Breusch-Pagan (heterocedasticidade)
bp1 <- bptest(m1)
print(bp1)
acf(resid(m1), main = "FAC dos Resíduos - Modelo 1 (Q2)")

# ============================================================
# QUESTÃO 3 - Modelo com dummies sazonais
# ============================================================
m3 <- lm(setor09 ~ cambio + ibcbr +
           fev + mar + abr + mai + jun + jul + ago + set + out + nov + dez,
         data = d)
summary(m3)
plot(d$data, d$setor09, type="l", col="black", main="Setor 09 Real vs Ajustado (Modelo 3)")
lines(d$data, fitted(m3), col="blue")
legend("topright", legend=c("Real", "Ajustado"), col=c("black", "blue"), lty=1)

# ============================================================
# QUESTÃO 4 - Ljung-Box e Breusch-Pagan no modelo 3
# ============================================================
# fitdf = 13 (cambio + ibcbr + 11 dummies)
lb3 <- Box.test(resid(m3), lag = 24, type = "Ljung-Box", fitdf = 13)
print(lb3)

bp3 <- bptest(m3)
print(bp3)

# ============================================================
# QUESTÃO 5 - Modelo com defasagens (t-1)
# ============================================================
d$setor09_l1 <- c(NA, head(d$setor09, -1))
d$cambio_l1  <- c(NA, head(d$cambio,  -1))

m5 <- lm(setor09 ~ cambio + ibcbr + setor09_l1 + cambio_l1 +
           fev + mar + abr + mai + jun + jul + ago + set + out + nov + dez,
         data = d)
summary(m5)

# Impacto total do repasse cambial (curto + longo prazo):
# beta1 (cambio_t) + beta4/(1-beta3) (efeito dinâmico via cambio_{t-1} e setor_{t-1})
b <- coef(m5)
repasse_curto <- b["cambio"]
repasse_longo <- (b["cambio"] + b["cambio_l1"]) / (1 - b["setor09_l1"])
cat("\nRepasse cambial de curto prazo:", round(repasse_curto, 4), "\n")
cat("Repasse cambial de longo prazo:", round(repasse_longo, 4), "\n")

# ============================================================
# QUESTÃO 6 - Teste F: modelo 3 (restrito) vs modelo 5 (irrestrito)
# ============================================================

# 1. Reestimamos m3 usando apenas as observações a partir da segunda linha
m3_ajustado <- lm(setor09 ~ cambio + ibcbr +
                    fev + mar + abr + mai + jun + jul + ago + set + out + nov + dez,
                  data = d[-1, ]) 

# 2. Rodamos o teste F comparando com o m5 (que já existe no seu ambiente)
anova(m3_ajustado, m5)

# 3. Alternativa via teste de hipótese (usando o pacote car):
# linearHypothesis(m5, c("setor09_l1 = 0", "cambio_l1 = 0"))

# ============================================================
# QUESTÃO 7 - Ljung-Box e Breusch-Pagan no modelo 5
# ============================================================
# fitdf = 15 (cambio + ibcbr + setor09_l1 + cambio_l1 + 11 dummies)
# Lembre-se de usar o m5_clean se você o criou, ou o próprio m5.
lb5 <- Box.test(resid(m5), lag = 24, type = "Ljung-Box", fitdf = 15)
print(lb5)

bp5 <- bptest(m5)
print(bp5)

# ============================================================
# QUESTÃO 8 - Erros robustos HAC (Newey-West)
# ============================================================
# HAC com lag escolhido automaticamente (Newey-West)
coeftest(m5, vcov = NeweyWest(m5, lag = NULL, prewhite = FALSE))

# Comparação lado a lado: OLS clássico vs HAC
cat("\n--- Coeficientes (OLS) ---\n")
print(summary(m5)$coefficients)

cat("\n--- Coeficientes (HAC/Newey-West) ---\n")
print(coeftest(m5, vcov = NeweyWest(m5, prewhite = FALSE)))

# Extraindo os erros padrão
se_ols <- summary(m5)$coefficients[, "Std. Error"]
se_hac <- coeftest(m5, vcov = NeweyWest(m5, prewhite = FALSE))[, "Std. Error"]

# Pegando apenas as variáveis de interesse para o gráfico
vars <- c("cambio", "ibcbr", "setor09_l1", "cambio_l1")
matrix_se <- rbind(se_ols[vars], se_hac[vars])
colnames(matrix_se) <- vars

barplot(matrix_se, beside=TRUE, col=c("gray", "darkblue"),
        main="Erros Padrão: OLS vs HAC",
        legend.text=c("OLS", "HAC"), args.legend=list(x="topright"))
# ------------------------------------------------------------
# Discussão (Q8): possíveis melhorias de especificação
# ------------------------------------------------------------
# - Incluir mais defasagens de cambio e setor09 (modelo ADL(p,q))
# - Testar quebras estruturais (pandemia 2020, greve caminhoneiros 2018)
#   com dummies de intervenção ou teste de Chow / Quandt-Andrews.
# - Modelar sazonalidade com Fourier ou SARIMA em vez de dummies.
# - Considerar variável dependente em log ou usar modelo em diferenças.
# - Testar não-linearidade (ex.: efeito assimétrico do câmbio: apreciação
#   vs depreciação) com dummies de sinal.
# - Verificar estabilidade dos parâmetros com CUSUM.
# ============================================================