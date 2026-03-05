.class public abstract Lt/a;
.super Lt/b;
.source "SourceFile"


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Lt/b;-><init>()V

    return-void
.end method


# virtual methods
.method public a(Ljava/lang/Object;)V
    .locals 1

    invoke-virtual {p0}, Lt/a;->o()Lt/f;

    move-result-object v0

    invoke-interface {v0, p1}, Lt/f;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 1

    invoke-virtual {p0}, Lt/a;->o()Lt/f;

    move-result-object v0

    invoke-interface {v0, p1, p2, p3}, Lt/f;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method protected abstract o()Lt/f;
.end method
