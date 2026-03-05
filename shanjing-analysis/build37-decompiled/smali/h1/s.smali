.class public final Lh1/s;
.super Lh1/m1;
.source "SourceFile"

# interfaces
.implements Lh1/r;


# instance fields
.field public final h:Lh1/t;


# direct methods
.method public constructor <init>(Lh1/t;)V
    .locals 0

    invoke-direct {p0}, Lh1/m1;-><init>()V

    iput-object p1, p0, Lh1/s;->h:Lh1/t;

    return-void
.end method


# virtual methods
.method public f(Ljava/lang/Throwable;)Z
    .locals 1

    invoke-virtual {p0}, Lh1/q1;->z()Lh1/r1;

    move-result-object v0

    invoke-virtual {v0, p1}, Lh1/r1;->C(Ljava/lang/Throwable;)Z

    move-result p1

    return p1
.end method

.method public getParent()Lh1/k1;
    .locals 1

    invoke-virtual {p0}, Lh1/q1;->z()Lh1/r1;

    move-result-object v0

    return-object v0
.end method

.method public bridge synthetic invoke(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    check-cast p1, Ljava/lang/Throwable;

    invoke-virtual {p0, p1}, Lh1/s;->y(Ljava/lang/Throwable;)V

    sget-object p1, Lq0/q;->a:Lq0/q;

    return-object p1
.end method

.method public y(Ljava/lang/Throwable;)V
    .locals 1

    iget-object p1, p0, Lh1/s;->h:Lh1/t;

    invoke-virtual {p0}, Lh1/q1;->z()Lh1/r1;

    move-result-object v0

    invoke-interface {p1, v0}, Lh1/t;->d(Lh1/y1;)V

    return-void
.end method
