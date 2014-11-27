### ggpot testing
library(ggplot2)
R.version

diamonds
dsmall

set.seed(1410)
dsmall <- diamonds[sample(nrow(diamonds),100),]

dsmall

qplot(carat, price, data = diamonds)
qplot(log(carat), log(price), data = diamonds)
qplot(carat,x*y*z,data = diamonds)

qplot(carat, price, data = dsmall, colour = color)
qplot(carat, price, data = dsmall, shape = cut)
qplot(carat, price, data = dsmall, shape = cut, colour = color)
qplot(carat, price, data = diamonds, alpha = I(1/10), geom=c("point","smooth"))

head(economics)
qplot(date, unemploy / pop, data = economics, geom = "line")
qplot(date, uempmed, data = economics, geom = "line")

### chapter 4

p <- ggplot(diamonds, aes(carat, price, colour = cut))
p <- p + layer(geom = "point")
p


p <- ggplot(diamonds, aes(x = carat))
p <- p + layer(
  geom = "bar",
  geom_params = list(fill = "steelblue"),
  stat = "bin",
  stat_params = list(binwidth = 2)
)
p

p <- ggplot(mtcars, aes(x = mpg, y = wt))
p + geom_point()
p + geom_point(aes(colour = factor(cyl)))
p + geom_point(aes(y = disp))

library(nlme);Oxboys
model <- lme(height ~ age, data = Oxboys, random=~1+age|Subject)
oplot <- ggplot(Oxboys, aes(age, height, group = Subject)) + geom_line()

age_grid <- seq(-1, 1, length = 10)
subjects <- unique(Oxboys$Subject)

preds <- expand.grid(age = age_grid, Subject = subjects)
preds$height <- predict(model, preds)

oplot + geom_line(data = preds, colour = "#3366FF", size= 0.4)

Oxboys$fitted <- predict(model)
Oxboys$resid <- with(Oxboys, fitted - height)

oplot %+% Oxboys + aes(y = resid) + geom_smooth(aes(group=1))

model2 <- update(model, height ~ age + I(age ^ 2))
Oxboys$fitted2 <- predict(model2)
Oxboys$resid2 <- with(Oxboys, fitted2 - height)

oplot %+% Oxboys + aes(y = resid2) + geom_smooth(aes(group=1))
