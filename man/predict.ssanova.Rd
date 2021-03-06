\name{predict.ssanova}
\alias{predict.ssanova}
\alias{predict.ssanova0}
\alias{predict1}
\alias{predict1.ssanova}
\title{Predicting from Smoothing Spline ANOVA Fits}
\description{
    Evaluate terms in a smoothing spline ANOVA fit at arbitrary points.
    Standard errors of the terms can be requested for use in
    constructing Bayesian confidence intervals.
}
\usage{
\method{predict}{ssanova}(object, newdata, se.fit=FALSE,
                          include=c(object$terms$labels,object$lab.p), ...)
\method{predict}{ssanova0}(object, newdata, se.fit=FALSE,
                           include=c(object$terms$labels,object$lab.p), ...)
\method{predict1}{ssanova}(object, contr=c(1,-1), newdata, se.fit=TRUE,
                           include=c(object$terms$labels,object$lab.p), ...)
}
\arguments{
    \item{object}{Object of class inheriting from \code{"ssanova"}.}
    \item{newdata}{Data frame or model frame in which to predict.}
    \item{se.fit}{Flag indicating if standard errors are required.}
    \item{include}{List of model terms to be included in the
	prediction.  The \code{offset} term, if present, is to be
	specified by \code{"offset"}.}
    \item{contr}{Contrast coefficients.}
    \item{...}{Ignored.}
}
\value{
    For \code{se.fit=FALSE}, \code{predict.ssanova} returns a vector of
    the evaluated fit.

    For \code{se.fit=TRUE}, \code{predict.ssanova} returns a list
    consisting of the following components.
    \item{fit}{Vector of evaluated fit.}
    \item{se.fit}{Vector of standard errors.}
}
\note{
    For mixed-effect models through \code{\link{ssanova}} or
    \code{\link{gssanova}}, the Z matrix is set to 0 if not supplied.
    To supply the Z matrix, add a component \code{random=I(...)} in
    \code{newdata}, where the as-is function \code{I(...)} preserves the
    integrity of the Z matrix in data frame.

    \code{predict1.ssanova} takes a list of data frames in
    \code{newdata} representing x1, x2, etc.  By default, it calculates
    f(x1)-f(x2) along with standard errors.  While pairwise contrast is
    the targeted application, all linear combinations can be computed.
}
\seealso{
    Fitting functions \code{\link{ssanova}}, \code{\link{ssanova0}},
    \code{\link{gssanova}}, \code{\link{gssanova0}} and
    methods \code{\link{summary.ssanova}},
    \code{\link{summary.gssanova}}, \code{\link{summary.gssanova0}},
    \code{\link{project.ssanova}}, \code{\link{fitted.ssanova}}.
}
\author{Chong Gu, \email{chong@stat.purdue.edu}}
\references{
    Gu, C. (1992), Penalized likelihood regression: a Bayesian
    analysis.  \emph{Statistica Sinica}, \bold{2}, 255--264.

    Gu, C. and Wahba, G. (1993), Smoothing spline ANOVA with
    component-wise Bayesian "confidence intervals."  \emph{Journal of
    Computational and Graphical Statistics}, \bold{2}, 97--117.

    Kim, Y.-J. and Gu, C. (2004), Smoothing spline Gaussian regression:
    more scalable computation via efficient approximation.
    \emph{Journal of the Royal Statistical Society, Ser. B}, \bold{66},
    337--356.
}
\examples{
## THE FOLLOWING EXAMPLE IS TIME-CONSUMING
\dontrun{
## Fit a model with cubic and thin-plate marginals, where geog is 2-D
data(LakeAcidity)
fit <- ssanova(ph~log(cal)*geog,,LakeAcidity)
## Obtain estimates and standard errors on a grid
new <- data.frame(cal=1,geog=I(matrix(0,1,2)))
new <- model.frame(~log(cal)+geog,new)
predict(fit,new,se=TRUE)
## Evaluate the geog main effect
predict(fit,new,se=TRUE,inc="geog")
## Evaluate the sum of the geog main effect and the interaction
predict(fit,new,se=TRUE,inc=c("geog","log(cal):geog"))
## Evaluate the geog main effect on a grid
grid <- seq(-.04,.04,len=21)
new <- model.frame(~geog,list(geog=cbind(rep(grid,21),rep(grid,rep(21,21)))))
est <- predict(fit,new,se=TRUE,inc="geog")
## Plot the fit and standard error
par(pty="s")
contour(grid,grid,matrix(est$fit,21,21),col=1)
contour(grid,grid,matrix(est$se,21,21),add=TRUE,col=2)
## Clean up
rm(LakeAcidity,fit,new,grid,est)
dev.off()
}
}
\keyword{models}
\keyword{regression}
\keyword{smooth}
